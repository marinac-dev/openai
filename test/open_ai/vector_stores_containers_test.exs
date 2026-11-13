defmodule OpenAi.VectorStoresContainersTest do
  use ExUnit.Case, async: true

  alias OpenAi.{Client, Containers, VectorStores}
  alias OpenAi.Containers.Files, as: ContainerFiles
  alias OpenAi.VectorStores.{FileBatches, Files}

  defp client(body \\ "{}", content_type \\ "application/json") do
    owner = self()

    Client.new(
      api_key: "test-key",
      base_url: "https://example.test/v1",
      max_retries: 0,
      requester: fn request, _finch, _opts ->
        send(owner, {:request, request})
        {:ok, %Finch.Response{status: 200, headers: [{"content-type", content_type}], body: body}}
      end
    )
  end

  test "every operation uses the right method, encoded path, query, and body" do
    c = client()
    b = %{a: 1}
    q = [limit: 2]

    cases = [
      {fn -> VectorStores.list(c, q) end, "GET", "/v1/vector_stores", "limit=2", nil},
      {fn -> VectorStores.create(c, b) end, "POST", "/v1/vector_stores", nil, b},
      {fn -> VectorStores.retrieve(c, "vs 1") end, "GET", "/v1/vector_stores/vs%201", nil, nil},
      {fn -> VectorStores.update(c, "vs 1", b) end, "POST", "/v1/vector_stores/vs%201", nil, b},
      {fn -> VectorStores.delete(c, "vs 1") end, "DELETE", "/v1/vector_stores/vs%201", nil, nil},
      {fn -> VectorStores.search(c, "vs 1", b) end, "POST", "/v1/vector_stores/vs%201/search", nil, b},
      {fn -> Files.list(c, "vs 1", q) end, "GET", "/v1/vector_stores/vs%201/files", "limit=2", nil},
      {fn -> Files.create(c, "vs 1", b) end, "POST", "/v1/vector_stores/vs%201/files", nil, b},
      {fn -> Files.retrieve(c, "vs 1", "f 1") end, "GET", "/v1/vector_stores/vs%201/files/f%201", nil, nil},
      {fn -> Files.update(c, "vs 1", "f 1", b) end, "POST", "/v1/vector_stores/vs%201/files/f%201", nil, b},
      {fn -> Files.delete(c, "vs 1", "f 1") end, "DELETE", "/v1/vector_stores/vs%201/files/f%201", nil, nil},
      {fn -> Files.content(c, "vs 1", "f 1") end, "GET", "/v1/vector_stores/vs%201/files/f%201/content", nil, nil},
      {fn -> FileBatches.create(c, "vs 1", b) end, "POST", "/v1/vector_stores/vs%201/file_batches", nil, b},
      {fn -> FileBatches.retrieve(c, "vs 1", "b 1") end, "GET", "/v1/vector_stores/vs%201/file_batches/b%201", nil,
       nil},
      {fn -> FileBatches.cancel(c, "vs 1", "b 1") end, "POST", "/v1/vector_stores/vs%201/file_batches/b%201/cancel",
       nil, nil},
      {fn -> FileBatches.list_files(c, "vs 1", "b 1", q) end, "GET",
       "/v1/vector_stores/vs%201/file_batches/b%201/files", "limit=2", nil},
      {fn -> Containers.list(c, q) end, "GET", "/v1/containers", "limit=2", nil},
      {fn -> Containers.create(c, b) end, "POST", "/v1/containers", nil, b},
      {fn -> Containers.retrieve(c, "c 1") end, "GET", "/v1/containers/c%201", nil, nil},
      {fn -> Containers.delete(c, "c 1") end, "DELETE", "/v1/containers/c%201", nil, nil},
      {fn -> ContainerFiles.list(c, "c 1", q) end, "GET", "/v1/containers/c%201/files", "limit=2", nil},
      {fn -> ContainerFiles.create(c, "c 1", b) end, "POST", "/v1/containers/c%201/files", nil, b},
      {fn -> ContainerFiles.retrieve(c, "c 1", "f 1") end, "GET", "/v1/containers/c%201/files/f%201", nil, nil},
      {fn -> ContainerFiles.delete(c, "c 1", "f 1") end, "DELETE", "/v1/containers/c%201/files/f%201", nil, nil}
    ]

    for {call, method, path, query, body} <- cases do
      assert {:ok, %{}} = call.()
      assert_receive {:request, request}
      assert request.method == method
      assert request.path == path
      assert request.query == query
      if body, do: assert(Jason.decode!(request.body) == %{"a" => 1})
    end
  end

  test "container file content returns raw bytes" do
    c = client(<<0, 1, 255>>, "application/octet-stream")
    assert {:ok, <<0, 1, 255>>} = ContainerFiles.content(c, "c 1", "f 1")
    assert_receive {:request, request}
    assert request.method == "GET"
    assert request.path == "/v1/containers/c%201/files/f%201/content"
  end

  test "container file upload sends multipart" do
    c = client()
    assert {:ok, %{}} = ContainerFiles.upload(c, "c 1", %{file: {:file_content, "hi", "a.txt"}})
    assert_receive {:request, request}
    assert request.path == "/v1/containers/c%201/files"
    assert {_, "multipart/form-data" <> _} = List.keyfind(request.headers, "content-type", 0)
  end
end
