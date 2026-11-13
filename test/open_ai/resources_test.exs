defmodule OpenAi.ResourcesTest do
  use ExUnit.Case, async: true

  alias OpenAi.{Client, Embeddings, Files, Models, Moderations}

  test "models, files, embeddings, and moderations send the expected requests" do
    client = client(fn _request -> json("{}") end)

    requests = [
      {fn -> Models.list(client) end, "GET", "/models", nil},
      {fn -> Models.retrieve(client, "ft: 1") end, "GET", "/models/ft%3A%201", nil},
      {fn -> Models.delete(client, "ft: 1") end, "DELETE", "/models/ft%3A%201", nil},
      {fn -> Files.list(client) end, "GET", "/files", nil},
      {fn -> Files.retrieve(client, "file 1") end, "GET", "/files/file%201", nil},
      {fn -> Files.delete(client, "file 1") end, "DELETE", "/files/file%201", nil},
      {fn -> Embeddings.create(client, %{model: "m", input: "x"}) end, "POST", "/embeddings",
       %{"model" => "m", "input" => "x"}},
      {fn -> Moderations.create(client, %{input: "x"}) end, "POST", "/moderations", %{"input" => "x"}}
    ]

    for {call, method, path, body} <- requests do
      assert {:ok, _} = call.()
      assert_receive {:request, request}
      assert request.method == method
      assert request.path == "/v1" <> path
      if body, do: assert(Jason.decode!(request.body) == body)
    end
  end

  test "file content returns the raw binary" do
    client =
      client(fn _request ->
        {:ok, %Finch.Response{status: 200, headers: [{"content-type", "application/octet-stream"}], body: <<0, 1, 2>>}}
      end)

    assert {:ok, <<0, 1, 2>>} = Files.content(client, "file 1")
    assert_receive {:request, %{path: "/v1/files/file%201/content"}}
  end

  defp client(respond) do
    owner = self()

    Client.new(
      api_key: "test-key",
      base_url: "https://example.test/v1",
      max_retries: 0,
      requester: fn request, _finch, _opts ->
        send(owner, {:request, request})
        respond.(request)
      end
    )
  end

  defp json(body),
    do: {:ok, %Finch.Response{status: 200, headers: [{"content-type", "application/json"}], body: body}}
end
