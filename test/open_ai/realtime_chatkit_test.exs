defmodule OpenAi.RealtimeChatKitTest do
  use ExUnit.Case, async: true

  alias OpenAi.ChatKit.Sessions, as: ChatKitSessions
  alias OpenAi.ChatKit.Threads
  alias OpenAi.Client
  alias OpenAi.Realtime.{Calls, ClientSecrets, TranscriptionSessions, Translations}
  alias OpenAi.Realtime.Sessions, as: RealtimeSessions

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

  test "every operation maps to its method, encoded path, body and query" do
    c = client()

    cases = [
      {fn -> Calls.accept(c, "c 1", %{model: "m"}) end, "POST", "/v1/realtime/calls/c%201/accept", %{"model" => "m"}},
      {fn -> Calls.hangup(c, "c 1") end, "POST", "/v1/realtime/calls/c%201/hangup", nil},
      {fn -> Calls.refer(c, "c 1", %{target_uri: "t"}) end, "POST", "/v1/realtime/calls/c%201/refer",
       %{"target_uri" => "t"}},
      {fn -> Calls.reject(c, "c 1") end, "POST", "/v1/realtime/calls/c%201/reject", %{}},
      {fn -> ClientSecrets.create(c, %{a: 1}) end, "POST", "/v1/realtime/client_secrets", %{"a" => 1}},
      {fn -> RealtimeSessions.create(c, %{a: 1}) end, "POST", "/v1/realtime/sessions", %{"a" => 1}},
      {fn -> TranscriptionSessions.create(c, %{a: 1}) end, "POST", "/v1/realtime/transcription_sessions", %{"a" => 1}},
      {fn -> Translations.create_client_secret(c, %{a: 1}) end, "POST", "/v1/realtime/translations/client_secrets",
       %{"a" => 1}},
      {fn -> ChatKitSessions.create(c, %{a: 1}) end, "POST", "/v1/chatkit/sessions", %{"a" => 1}},
      {fn -> ChatKitSessions.cancel(c, "s 1") end, "POST", "/v1/chatkit/sessions/s%201/cancel", nil},
      {fn -> Threads.list(c, limit: 2) end, "GET", "/v1/chatkit/threads", nil},
      {fn -> Threads.retrieve(c, "t 1") end, "GET", "/v1/chatkit/threads/t%201", nil},
      {fn -> Threads.delete(c, "t 1") end, "DELETE", "/v1/chatkit/threads/t%201", nil},
      {fn -> Threads.list_items(c, "t 1", limit: 3) end, "GET", "/v1/chatkit/threads/t%201/items", nil}
    ]

    for {call, method, path, body} <- cases do
      assert {:ok, _} = call.()
      assert_receive {:request, request}
      assert request.method == method
      assert request.path == path
      if body, do: assert(Jason.decode!(request.body) == body)

      if String.contains?(path, "chatkit") do
        assert {_, "chatkit_beta=v1"} = List.keyfind(request.headers, "openai-beta", 0)
      end
    end
  end

  test "list passes query" do
    assert {:ok, _} = Threads.list_items(client(), "t", limit: 3)
    assert_receive {:request, request}
    assert request.query == "limit=3"
  end

  test "calls create sends multipart and returns raw SDP" do
    c = client("v=0\r\nanswer", "application/sdp")
    assert {:ok, "v=0\r\nanswer"} = Calls.create(c, %{sdp: "v=0 offer", session: %{type: "realtime"}})
    assert_receive {:request, request}
    assert request.path == "/v1/realtime/calls"
    assert {:stream, stream} = request.body
    body = stream |> Enum.to_list() |> IO.iodata_to_binary()
    assert body =~ "v=0 offer"
    assert body =~ ~s({"type":"realtime"})
  end
end
