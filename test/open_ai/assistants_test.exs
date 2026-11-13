defmodule OpenAi.AssistantsTest do
  use ExUnit.Case, async: true

  alias OpenAi.{Assistants, Client, Threads}
  alias OpenAi.Threads.{Messages, Runs}
  alias OpenAi.Threads.Runs.Steps

  test "every operation uses the expected method and encoded path" do
    c = client()

    cases = [
      {"GET", "/v1/assistants", fn -> Assistants.list(c) end},
      {"POST", "/v1/assistants", fn -> Assistants.create(c, %{}) end},
      {"GET", "/v1/assistants/a%201", fn -> Assistants.retrieve(c, "a 1") end},
      {"POST", "/v1/assistants/a%201", fn -> Assistants.update(c, "a 1", %{}) end},
      {"DELETE", "/v1/assistants/a%201", fn -> Assistants.delete(c, "a 1") end},
      {"POST", "/v1/threads", fn -> Threads.create(c) end},
      {"POST", "/v1/threads/runs", fn -> Threads.create_and_run(c, %{}) end},
      {"GET", "/v1/threads/t%201", fn -> Threads.retrieve(c, "t 1") end},
      {"POST", "/v1/threads/t%201", fn -> Threads.update(c, "t 1", %{}) end},
      {"DELETE", "/v1/threads/t%201", fn -> Threads.delete(c, "t 1") end},
      {"GET", "/v1/threads/t%201/messages", fn -> Messages.list(c, "t 1") end},
      {"POST", "/v1/threads/t%201/messages", fn -> Messages.create(c, "t 1", %{}) end},
      {"GET", "/v1/threads/t%201/messages/m%201", fn -> Messages.retrieve(c, "t 1", "m 1") end},
      {"POST", "/v1/threads/t%201/messages/m%201", fn -> Messages.update(c, "t 1", "m 1", %{}) end},
      {"DELETE", "/v1/threads/t%201/messages/m%201", fn -> Messages.delete(c, "t 1", "m 1") end},
      {"GET", "/v1/threads/t%201/runs", fn -> Runs.list(c, "t 1") end},
      {"POST", "/v1/threads/t%201/runs", fn -> Runs.create(c, "t 1", %{}) end},
      {"GET", "/v1/threads/t%201/runs/r%201", fn -> Runs.retrieve(c, "t 1", "r 1") end},
      {"POST", "/v1/threads/t%201/runs/r%201", fn -> Runs.update(c, "t 1", "r 1", %{}) end},
      {"POST", "/v1/threads/t%201/runs/r%201/cancel", fn -> Runs.cancel(c, "t 1", "r 1") end},
      {"POST", "/v1/threads/t%201/runs/r%201/submit_tool_outputs",
       fn -> Runs.submit_tool_outputs(c, "t 1", "r 1", %{}) end},
      {"GET", "/v1/threads/t%201/runs/r%201/steps", fn -> Steps.list(c, "t 1", "r 1") end},
      {"GET", "/v1/threads/t%201/runs/r%201/steps/s%201", fn -> Steps.retrieve(c, "t 1", "r 1", "s 1") end}
    ]

    for {method, path, call} <- cases do
      assert {:ok, _} = call.()
      assert_receive {:request, request}
      assert request.method == method
      assert request.path == path
      assert {"openai-beta", "assistants=v2"} in request.headers
    end
  end

  test "passes query parameters and bodies" do
    c = client()

    assert {:ok, _} = Steps.list(c, "t", "r", limit: 2, include: ["x"])
    assert_receive {:request, request}
    assert request.query =~ "limit=2"
    assert request.query =~ "include%5B%5D=x"

    assert {:ok, _} = Assistants.create(c, %{model: "gpt-4o"})
    assert_receive {:request, request}
    assert Jason.decode!(request.body) == %{"model" => "gpt-4o"}
  end

  test "stream variants force stream: true" do
    c = stream_client()

    assert {:ok, _} = Threads.stream_create_and_run(c, %{assistant_id: "a"}, fn _ -> :ok end)
    assert_receive {:request, request}
    assert Jason.decode!(request.body) == %{"assistant_id" => "a", "stream" => true}

    assert {:ok, _} = Runs.stream_create(c, "t", %{"assistant_id" => "a"}, fn _ -> :ok end)
    assert_receive {:request, request}
    assert request.path == "/v1/threads/t/runs"
    assert Jason.decode!(request.body)["stream"] == true

    assert {:ok, _} = Runs.stream_submit_tool_outputs(c, "t", "r", %{tool_outputs: []}, fn _ -> :ok end)
    assert_receive {:request, request}
    assert request.path == "/v1/threads/t/runs/r/submit_tool_outputs"
    assert Jason.decode!(request.body)["stream"] == true
  end

  defp stream_client do
    owner = self()

    streamer = fn request, _finch, acc, callback, _options ->
      send(owner, {:request, request})
      {:ok, callback.({:status, 200}, acc)}
    end

    Client.new(api_key: "test-key", base_url: "https://example.test/v1", max_retries: 0, streamer: streamer)
  end

  defp client do
    owner = self()

    Client.new(
      api_key: "test-key",
      base_url: "https://example.test/v1",
      max_retries: 0,
      requester: fn request, _finch, _opts ->
        send(owner, {:request, request})
        {:ok, %Finch.Response{status: 200, headers: [{"content-type", "application/json"}], body: "{}"}}
      end
    )
  end
end
