defmodule OpenAi.ChatCompletionsTest do
  use ExUnit.Case, async: true

  alias OpenAi.Chat.Completions, as: ChatCompletions
  alias OpenAi.{Client, Completions, Conversations}

  test "endpoints send the expected requests" do
    client = client()

    requests = [
      {fn -> ChatCompletions.create(client, %{model: "m"}) end, "POST", "/chat/completions", %{"model" => "m"}, nil},
      {fn -> ChatCompletions.list(client, limit: 5) end, "GET", "/chat/completions", nil, "limit=5"},
      {fn -> ChatCompletions.retrieve(client, "c 1") end, "GET", "/chat/completions/c%201", nil, nil},
      {fn -> ChatCompletions.update(client, "c 1", %{metadata: %{"a" => "b"}}) end, "POST", "/chat/completions/c%201",
       %{"metadata" => %{"a" => "b"}}, nil},
      {fn -> ChatCompletions.delete(client, "c 1") end, "DELETE", "/chat/completions/c%201", nil, nil},
      {fn -> ChatCompletions.list_messages(client, "c 1", after: "m 1") end, "GET", "/chat/completions/c%201/messages",
       nil, "after=m+1"},
      {fn -> Completions.create(client, %{model: "m", prompt: "hi"}) end, "POST", "/completions",
       %{"model" => "m", "prompt" => "hi"}, nil},
      {fn -> Conversations.create(client) end, "POST", "/conversations", %{}, nil},
      {fn -> Conversations.retrieve(client, "conv 1") end, "GET", "/conversations/conv%201", nil, nil},
      {fn -> Conversations.update(client, "conv 1", %{metadata: %{}}) end, "POST", "/conversations/conv%201",
       %{"metadata" => %{}}, nil},
      {fn -> Conversations.delete(client, "conv 1") end, "DELETE", "/conversations/conv%201", nil, nil},
      {fn -> Conversations.create_items(client, "conv 1", [%{type: "message"}], include: ["a"]) end, "POST",
       "/conversations/conv%201/items", %{"items" => [%{"type" => "message"}]}, "include%5B%5D=a"},
      {fn -> Conversations.list_items(client, "conv 1", limit: 2) end, "GET", "/conversations/conv%201/items", nil,
       "limit=2"},
      {fn -> Conversations.retrieve_item(client, "conv 1", "item 1") end, "GET",
       "/conversations/conv%201/items/item%201", nil, nil},
      {fn -> Conversations.delete_item(client, "conv 1", "item 1") end, "DELETE",
       "/conversations/conv%201/items/item%201", nil, nil}
    ]

    for {call, method, path, body, query} <- requests do
      assert {:ok, _} = call.()
      assert_receive {:request, request}
      assert request.method == method
      assert request.path == "/v1" <> path
      assert (request.query || "") == (query || "")
      if body, do: assert(Jason.decode!(request.body) == body)
    end
  end

  test "stream variants force stream: true" do
    owner = self()

    streamer = fn request, _finch, acc, callback, _options ->
      send(owner, {:stream_request, request})
      acc = callback.({:status, 200}, acc)
      acc = callback.({:headers, [{"content-type", "text/event-stream"}]}, acc)
      acc = callback.({:data, "data: {\"id\":\"x\"}\n\ndata: [DONE]\n\n"}, acc)
      {:ok, acc}
    end

    client = client(streamer: streamer)

    assert {:ok, _} = ChatCompletions.stream(client, %{model: "m"}, &send(owner, {:event, &1}))
    assert_receive {:stream_request, request}
    assert request.path == "/v1/chat/completions"
    assert Jason.decode!(request.body)["stream"] == true
    assert_receive {:event, %{"id" => "x"}}

    assert {:ok, _} = Completions.stream(client, %{"model" => "m"}, fn _ -> :ok end)
    assert_receive {:stream_request, request}
    assert request.path == "/v1/completions"
    assert Jason.decode!(request.body) == %{"model" => "m", "stream" => true}
  end

  describe "accumulate/1" do
    test "concatenates content across chunks and takes usage from the final chunk" do
      chunks = [
        chunk(%{"role" => "assistant", "content" => ""}, nil, 0, id: "chatcmpl-1", system_fingerprint: "fp_1"),
        chunk(%{"content" => "Hel"}, nil, 0, id: "chatcmpl-1"),
        chunk(%{"content" => "lo"}, nil, 0, id: "chatcmpl-1"),
        chunk(%{}, "stop", 0, id: "chatcmpl-1"),
        %{
          "id" => "chatcmpl-1",
          "object" => "chat.completion.chunk",
          "created" => 1,
          "model" => "gpt-5.4",
          "choices" => [],
          "usage" => %{"prompt_tokens" => 3, "completion_tokens" => 2, "total_tokens" => 5}
        }
      ]

      assert ChatCompletions.accumulate(chunks) == %{
               "id" => "chatcmpl-1",
               "object" => "chat.completion",
               "created" => 1,
               "model" => "gpt-5.4",
               "system_fingerprint" => "fp_1",
               "usage" => %{"prompt_tokens" => 3, "completion_tokens" => 2, "total_tokens" => 5},
               "choices" => [
                 %{
                   "index" => 0,
                   "finish_reason" => "stop",
                   "logprobs" => nil,
                   "message" => %{"role" => "assistant", "content" => "Hello", "refusal" => nil}
                 }
               ]
             }
    end

    test "merges parallel tool call deltas by index" do
      chunks = [
        chunk(%{"role" => "assistant", "content" => nil, "tool_calls" => [call(0, "call_a", "get_weather", "")]}),
        chunk(%{"tool_calls" => [call(0, nil, nil, "{\"city\":")]}),
        chunk(%{"tool_calls" => [call(1, "call_b", "get_time", "")]}),
        chunk(%{"tool_calls" => [call(1, nil, nil, "{\"tz\":")]}),
        chunk(%{"tool_calls" => [call(0, nil, nil, "\"Paris\"}")]}),
        chunk(%{"tool_calls" => [call(1, nil, nil, "\"UTC\"}")]}),
        chunk(%{}, "tool_calls", 0)
      ]

      assert %{"choices" => [choice]} = ChatCompletions.accumulate(chunks)
      assert choice["finish_reason"] == "tool_calls"
      assert choice["message"]["content"] == nil

      assert choice["message"]["tool_calls"] == [
               %{
                 "id" => "call_a",
                 "type" => "function",
                 "function" => %{"name" => "get_weather", "arguments" => "{\"city\":\"Paris\"}"}
               },
               %{
                 "id" => "call_b",
                 "type" => "function",
                 "function" => %{"name" => "get_time", "arguments" => "{\"tz\":\"UTC\"}"}
               }
             ]
    end

    test "keeps interleaved choices separate and sorted by index" do
      chunks = [
        chunk(%{"role" => "assistant", "content" => "B1"}, nil, 1),
        chunk(%{"role" => "assistant", "content" => "A1"}, nil, 0),
        chunk(%{"content" => "A2"}, nil, 0),
        chunk(%{"refusal" => "no"}, nil, 1),
        chunk(%{}, "stop", 1),
        chunk(%{}, "length", 0)
      ]

      assert %{"choices" => [first, second]} = ChatCompletions.accumulate(chunks)

      assert %{"index" => 0, "finish_reason" => "length", "message" => %{"content" => "A1A2", "refusal" => nil}} =
               first

      assert %{"index" => 1, "finish_reason" => "stop", "message" => %{"content" => "B1", "refusal" => "no"}} =
               second

      refute Map.has_key?(first["message"], "tool_calls")
    end
  end

  defp chunk(delta, finish_reason \\ nil, index \\ 0, meta \\ []) do
    base = %{
      "id" => meta[:id] || "chatcmpl-1",
      "object" => "chat.completion.chunk",
      "created" => 1,
      "model" => "gpt-5.4",
      "choices" => [%{"index" => index, "delta" => delta, "finish_reason" => finish_reason}]
    }

    case meta[:system_fingerprint] do
      nil -> base
      fingerprint -> Map.put(base, "system_fingerprint", fingerprint)
    end
  end

  defp call(index, id, name, arguments) do
    function = reject_nil(%{"name" => name, "arguments" => arguments})
    reject_nil(%{"index" => index, "id" => id, "type" => id && "function", "function" => function})
  end

  defp reject_nil(map), do: Map.reject(map, fn {_key, value} -> is_nil(value) end)

  defp client(options \\ []) do
    owner = self()

    defaults = [
      api_key: "test-key",
      base_url: "https://example.test/v1",
      max_retries: 0,
      requester: fn request, _finch, _opts ->
        send(owner, {:request, request})
        {:ok, %Finch.Response{status: 200, headers: [{"content-type", "application/json"}], body: "{}"}}
      end
    ]

    Client.new(Keyword.merge(defaults, options))
  end
end
