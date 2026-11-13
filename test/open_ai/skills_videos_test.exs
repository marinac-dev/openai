defmodule OpenAi.SkillsVideosTest do
  use ExUnit.Case, async: true

  alias OpenAi.Client
  alias OpenAi.Skills
  alias OpenAi.Skills.Versions
  alias OpenAi.Videos
  alias OpenAi.Videos.Characters

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

  defp upload do
    {:file_content, "data", "a.bin"}
  end

  test "every function sends the expected method and encoded path" do
    c = client()

    cases = [
      {"POST", "/v1/skills", fn -> Skills.create(c, %{files: upload()}) end},
      {"GET", "/v1/skills", fn -> Skills.list(c) end},
      {"GET", "/v1/skills/sk%201", fn -> Skills.retrieve(c, "sk 1") end},
      {"POST", "/v1/skills/sk%201", fn -> Skills.update(c, "sk 1", %{default_version: "2"}) end},
      {"DELETE", "/v1/skills/sk%201", fn -> Skills.delete(c, "sk 1") end},
      {"GET", "/v1/skills/sk%201/content", fn -> Skills.content(c, "sk 1") end},
      {"POST", "/v1/skills/sk%201/versions", fn -> Versions.create(c, "sk 1", %{files: [upload()]}) end},
      {"GET", "/v1/skills/sk%201/versions", fn -> Versions.list(c, "sk 1") end},
      {"GET", "/v1/skills/sk%201/versions/v%201", fn -> Versions.retrieve(c, "sk 1", "v 1") end},
      {"DELETE", "/v1/skills/sk%201/versions/v%201", fn -> Versions.delete(c, "sk 1", "v 1") end},
      {"GET", "/v1/skills/sk%201/versions/v%201/content", fn -> Versions.content(c, "sk 1", "v 1") end},
      {"POST", "/v1/videos", fn -> Videos.create(c, %{prompt: "p"}) end},
      {"GET", "/v1/videos", fn -> Videos.list(c) end},
      {"GET", "/v1/videos/vid%201", fn -> Videos.retrieve(c, "vid 1") end},
      {"DELETE", "/v1/videos/vid%201", fn -> Videos.delete(c, "vid 1") end},
      {"GET", "/v1/videos/vid%201/content", fn -> Videos.content(c, "vid 1") end},
      {"POST", "/v1/videos/vid%201/remix", fn -> Videos.remix(c, "vid 1", %{prompt: "p"}) end},
      {"POST", "/v1/videos/edits", fn -> Videos.edit(c, %{video: upload(), prompt: "p"}) end},
      {"POST", "/v1/videos/extensions", fn -> Videos.extend(c, %{video: upload(), prompt: "p"}) end},
      {"POST", "/v1/videos/characters", fn -> Characters.create(c, %{video: upload(), name: "n"}) end},
      {"GET", "/v1/videos/characters/ch%201", fn -> Characters.retrieve(c, "ch 1") end}
    ]

    for {method, path, call} <- cases do
      assert {:ok, _} = call.()
      assert_receive {:request, request}
      assert {request.method, request.path} == {method, path}
    end
  end

  test "update sends a JSON body and list sends query" do
    c = client()
    assert {:ok, _} = Skills.update(c, "sk", %{default_version: "2"})
    assert_receive {:request, request}
    assert Jason.decode!(request.body) == %{"default_version" => "2"}

    assert {:ok, _} = Videos.list(c, limit: 5, order: "desc")
    assert_receive {:request, request}
    assert request.query == "limit=5&order=desc"
  end

  test "skill version create encodes every file in a multipart body" do
    c = client()

    assert {:ok, _} =
             Versions.create(c, "sk", %{
               files: [{:file_content, "one", "a.txt"}, {:file_content, "two", "b.txt"}],
               default: true
             })

    assert_receive {:request, request}
    assert {:stream, stream} = request.body
    body = stream |> Enum.to_list() |> IO.iodata_to_binary()
    assert body =~ ~s(name="files[]"; filename="a.txt")
    assert body =~ ~s(name="files[]"; filename="b.txt")
    assert body =~ ~s(name="default")
  end

  test "video content returns raw bytes and passes variant" do
    c = client(<<0, 1, 2, 255>>, "video/mp4")
    assert {:ok, <<0, 1, 2, 255>>} = Videos.content(c, "vid", variant: "thumbnail")
    assert_receive {:request, request}
    assert request.query == "variant=thumbnail"
  end
end
