defmodule OpenAi.ClientTest do
  use ExUnit.Case, async: true

  alias OpenAi.{Client, Error, Files, Responses}

  test "encodes JSON requests, auth headers, path segments, and repeated query values" do
    owner = self()

    client =
      client(
        organization: "org_123",
        project: "proj_123",
        requester: fn request, _finch, request_options ->
          send(owner, {:request, request, request_options})
          json_response(200, %{"id" => "resp_123"})
        end
      )

    assert {:ok, %{"id" => "resp_123"}} =
             Client.request(client, :post, "/responses/resp id",
               body: %{model: "gpt-5.4"},
               query: [include: ["a", "b"]]
             )

    assert_receive {:request, request, request_options}
    assert request.method == "POST"
    assert request.path == "/v1/responses/resp%20id"
    assert request.query == "include%5B%5D=a&include%5B%5D=b"
    assert Jason.decode!(request.body) == %{"model" => "gpt-5.4"}
    assert request_options[:receive_timeout] == 60_000
    assert header(request.headers, "authorization") == "Bearer test-key"
    assert header(request.headers, "openai-organization") == "org_123"
    assert header(request.headers, "openai-project") == "proj_123"
    assert header(request.headers, "content-type") == "application/json"
  end

  test "returns normalized API errors with request metadata" do
    client =
      client(
        requester: fn _request, _finch, _options ->
          json_response(
            429,
            %{"error" => %{"message" => "Rate limit reached", "type" => "rate_limit_error", "code" => "rate_limit"}},
            [{"x-request-id", "req_123"}]
          )
        end
      )

    assert {:error, %Error{} = error} = Client.request(client, :get, "/models")
    assert error.status == 429
    assert error.message == "Rate limit reached"
    assert error.type == "rate_limit_error"
    assert error.code == "rate_limit"
    assert error.request_id == "req_123"
  end

  test "retries transient responses and honors retry-after-ms" do
    {:ok, counter} = Agent.start_link(fn -> 0 end)
    owner = self()

    client =
      client(
        max_retries: 1,
        sleep: fn delay -> send(owner, {:slept, delay}) end,
        requester: fn _request, _finch, _options ->
          attempt = Agent.get_and_update(counter, fn count -> {count, count + 1} end)

          if attempt == 0 do
            {:ok, %Finch.Response{status: 500, headers: [{"retry-after-ms", "25"}], body: "server error"}}
          else
            json_response(200, %{"ok" => true})
          end
        end
      )

    assert {:ok, %{"ok" => true}} = Client.request(client, :get, "/models")
    assert_receive {:slept, 25}
    assert Agent.get(counter, & &1) == 2
  end

  test "preserves binary response bodies when decoding is disabled" do
    client =
      client(
        requester: fn _request, _finch, _options ->
          {:ok, %Finch.Response{status: 200, headers: [{"content-type", "audio/mpeg"}], body: <<0, 1, 2>>}}
        end
      )

    assert {:ok, <<0, 1, 2>>} = Client.request(client, :post, "/audio/speech", decode: false)
  end

  test "decodes JSON API errors even when successful responses are binary" do
    client =
      client(
        requester: fn _request, _finch, _options ->
          json_response(401, %{"error" => %{"message" => "Bad key", "type" => "authentication_error"}})
        end
      )

    assert {:error, %Error{message: "Bad key", type: "authentication_error"}} =
             Client.request(client, :post, "/audio/speech", decode: false)
  end

  test "caps server-requested retry delays" do
    {:ok, counter} = Agent.start_link(fn -> 0 end)
    owner = self()

    client =
      client(
        max_retries: 1,
        retry_max_delay: 10,
        sleep: fn delay -> send(owner, {:capped_sleep, delay}) end,
        requester: fn _request, _finch, _options ->
          attempt = Agent.get_and_update(counter, fn count -> {count, count + 1} end)

          if attempt == 0 do
            {:ok, %Finch.Response{status: 429, headers: [{"retry-after", "999"}], body: ""}}
          else
            json_response(200, %{"ok" => true})
          end
        end
      )

    assert {:ok, %{"ok" => true}} = Client.request(client, :get, "/models")
    assert_receive {:capped_sleep, 10}
  end

  test "streams decoded SSE events across arbitrary chunk boundaries" do
    owner = self()

    streamer = fn request, _finch, acc, callback, _options ->
      send(owner, {:stream_request, request})

      acc = callback.({:status, 200}, acc)
      acc = callback.({:headers, [{"content-type", "text/event-stream"}, {"x-request-id", "req_stream"}]}, acc)
      acc = callback.({:data, "event: response.output_te"}, acc)
      acc = callback.({:data, "xt.delta\r\ndata: {\"type\":\"response.output_text.delta\",\"delta\":\"Hel"}, acc)
      acc = callback.({:data, "lo\"}\r\n\r\ndata: [DO"}, acc)
      acc = callback.({:data, "NE]\r\n\r\n"}, acc)
      {:ok, acc}
    end

    client = client(streamer: streamer)

    assert {:ok, response} =
             Responses.stream(client, %{model: "gpt-5.4", input: "Hello"}, fn event ->
               send(owner, {:event, event})
             end)

    assert response.status == 200
    assert response.request_id == "req_stream"
    assert_receive {:event, %{"type" => "response.output_text.delta", "delta" => "Hello"}}
    refute_receive {:event, _event}

    assert_receive {:stream_request, request}
    assert header(request.headers, "accept") == "text/event-stream"
    assert Jason.decode!(request.body)["stream"] == true
  end

  test "encodes multipart files and nested form fields" do
    owner = self()
    path = Path.join(System.tmp_dir!(), "openai-client-#{System.unique_integer([:positive])}.txt")
    File.write!(path, "training data")
    on_exit(fn -> File.rm(path) end)

    client =
      client(
        requester: fn request, _finch, _options ->
          send(owner, {:multipart_request, request})
          json_response(200, %{"id" => "file_123"})
        end
      )

    assert {:ok, %{"id" => "file_123"}} =
             Files.create(client, %{
               file: path,
               purpose: "fine-tune",
               expires_after: %{anchor: "created_at", seconds: 3_600}
             })

    assert_receive {:multipart_request, request}
    assert {:stream, stream} = request.body
    body = stream |> Enum.to_list() |> IO.iodata_to_binary()

    assert header(request.headers, "content-type") =~ "multipart/form-data; boundary="
    assert body =~ ~s(name="file")
    assert body =~ "training data"
    assert body =~ ~s(name="expires_after[anchor]")
    assert body =~ "created_at"
  end

  test "encodes in-memory files and list fields passed directly to request/4" do
    owner = self()

    client =
      client(
        requester: fn request, _finch, _options ->
          send(owner, {:multipart_request, request})
          json_response(200, %{"id" => "part_123"})
        end
      )

    assert {:ok, _body} =
             Client.request(client, :post, "/uploads/upload_123/parts",
               body: {:multipart, %{data: {:file_content, "chunk bytes", "part.bin"}, tags: ["a", "b"]}}
             )

    assert_receive {:multipart_request, request}
    {:stream, stream} = request.body
    body = stream |> Enum.to_list() |> IO.iodata_to_binary()

    assert body =~ ~s(name="data"; filename="part.bin")
    assert body =~ "chunk bytes"
    assert length(String.split(body, ~s(name="tags[]"))) == 3
  end

  test "sends the beta opt-in header required by Assistants, Threads, and ChatKit" do
    client = client([])

    for {path, expected} <- [
          {"/assistants", "assistants=v2"},
          {"/threads/thread_1/runs", "assistants=v2"},
          {"/chatkit/sessions", "chatkit_beta=v1"},
          {"/responses", nil}
        ] do
      assert {:ok, request} = Client.build_request(client, :get, path)
      assert header(request.headers, "openai-beta") == expected
    end

    assert {:ok, request} =
             Client.build_request(client, :get, "/assistants", headers: [{"OpenAI-Beta", "assistants=v3"}])

    assert header(request.headers, "openai-beta") == "assistants=v3"
  end

  test "targets beta Responses endpoints and forwards beta feature names" do
    owner = self()

    client =
      client(
        requester: fn request, _finch, _options ->
          send(owner, {:request, request})
          json_response(200, %{"input_tokens" => 3})
        end
      )

    assert {:ok, _body} =
             Responses.input_tokens(client, %{model: "gpt-5.4", input: "Hi"}, beta: ["feature-x", "feature-y"])

    assert_receive {:request, request}
    assert request.path == "/v1/responses/input_tokens"
    assert request.query == "beta=true"
    assert header(request.headers, "openai-beta") == "feature-x,feature-y"

    assert {:ok, _body} = Responses.retrieve(client, "resp_1", [include: ["x"]], beta: true)
    assert_receive {:request, request}
    assert URI.decode_query(request.query) == %{"include[]" => "x", "beta" => "true"}
    assert header(request.headers, "openai-beta") == nil
  end

  test "extracts output text from a Responses API object" do
    response = %{
      "output" => [
        %{"type" => "reasoning", "content" => []},
        %{
          "type" => "message",
          "content" => [
            %{"type" => "output_text", "text" => "Hello"},
            %{"type" => "refusal", "refusal" => ""},
            %{"type" => "output_text", "text" => " world"}
          ]
        }
      ]
    }

    assert Responses.output_text(response) == "Hello world"
  end

  defp client(options) do
    defaults = [api_key: "test-key", base_url: "https://example.test/v1", max_retries: 0]
    Client.new(Keyword.merge(defaults, options))
  end

  defp json_response(status, body, headers \\ []) do
    {:ok,
     %Finch.Response{
       status: status,
       headers: [{"content-type", "application/json"} | headers],
       body: Jason.encode!(body)
     }}
  end

  defp header(headers, name) do
    name = String.downcase(name)
    Enum.find_value(headers, fn {key, value} -> if String.downcase(key) == name, do: value end)
  end
end
