defmodule OpenAi.FineTuningEvalsTest do
  use ExUnit.Case, async: true

  alias OpenAi.Client
  alias OpenAi.Evals
  alias OpenAi.Evals.Runs
  alias OpenAi.Evals.Runs.OutputItems
  alias OpenAi.FineTuning.Checkpoints.Permissions
  alias OpenAi.FineTuning.Graders
  alias OpenAi.FineTuning.Jobs

  setup do
    owner = self()

    client =
      Client.new(
        api_key: "test-key",
        base_url: "https://example.test/v1",
        max_retries: 0,
        requester: fn request, _finch, _opts ->
          send(owner, {:request, request})
          {:ok, %Finch.Response{status: 200, headers: [{"content-type", "application/json"}], body: "{}"}}
        end
      )

    {:ok, client: client}
  end

  test "every operation uses the right method and encoded path", %{client: c} do
    body = %{a: 1}

    cases = [
      {fn -> Jobs.create(c, body) end, "POST", "/v1/fine_tuning/jobs", body},
      {fn -> Jobs.list(c, limit: 2) end, "GET", "/v1/fine_tuning/jobs", nil},
      {fn -> Jobs.retrieve(c, "j 1") end, "GET", "/v1/fine_tuning/jobs/j%201", nil},
      {fn -> Jobs.cancel(c, "j 1") end, "POST", "/v1/fine_tuning/jobs/j%201/cancel", nil},
      {fn -> Jobs.pause(c, "j 1") end, "POST", "/v1/fine_tuning/jobs/j%201/pause", nil},
      {fn -> Jobs.resume(c, "j 1") end, "POST", "/v1/fine_tuning/jobs/j%201/resume", nil},
      {fn -> Jobs.list_checkpoints(c, "j 1") end, "GET", "/v1/fine_tuning/jobs/j%201/checkpoints", nil},
      {fn -> Jobs.list_events(c, "j 1") end, "GET", "/v1/fine_tuning/jobs/j%201/events", nil},
      {fn -> Permissions.list(c, "ck 1") end, "GET", "/v1/fine_tuning/checkpoints/ck%201/permissions", nil},
      {fn -> Permissions.create(c, "ck 1", body) end, "POST", "/v1/fine_tuning/checkpoints/ck%201/permissions", body},
      {fn -> Permissions.delete(c, "ck 1", "p 1") end, "DELETE", "/v1/fine_tuning/checkpoints/ck%201/permissions/p%201",
       nil},
      {fn -> Graders.run(c, body) end, "POST", "/v1/fine_tuning/alpha/graders/run", body},
      {fn -> Graders.validate(c, body) end, "POST", "/v1/fine_tuning/alpha/graders/validate", body},
      {fn -> Evals.list(c) end, "GET", "/v1/evals", nil},
      {fn -> Evals.create(c, body) end, "POST", "/v1/evals", body},
      {fn -> Evals.retrieve(c, "e 1") end, "GET", "/v1/evals/e%201", nil},
      {fn -> Evals.update(c, "e 1", body) end, "POST", "/v1/evals/e%201", body},
      {fn -> Evals.delete(c, "e 1") end, "DELETE", "/v1/evals/e%201", nil},
      {fn -> Runs.list(c, "e 1") end, "GET", "/v1/evals/e%201/runs", nil},
      {fn -> Runs.create(c, "e 1", body) end, "POST", "/v1/evals/e%201/runs", body},
      {fn -> Runs.retrieve(c, "e 1", "r 1") end, "GET", "/v1/evals/e%201/runs/r%201", nil},
      {fn -> Runs.cancel(c, "e 1", "r 1") end, "POST", "/v1/evals/e%201/runs/r%201", nil},
      {fn -> Runs.delete(c, "e 1", "r 1") end, "DELETE", "/v1/evals/e%201/runs/r%201", nil},
      {fn -> OutputItems.list(c, "e 1", "r 1") end, "GET", "/v1/evals/e%201/runs/r%201/output_items", nil},
      {fn -> OutputItems.retrieve(c, "e 1", "r 1", "o 1") end, "GET", "/v1/evals/e%201/runs/r%201/output_items/o%201",
       nil}
    ]

    for {call, method, path, expected_body} <- cases do
      assert {:ok, _} = call.()
      assert_receive {:request, request}
      assert request.method == method
      assert request.path == path
      if expected_body, do: assert(Jason.decode!(request.body) == %{"a" => 1})
    end
  end

  test "list passes query params", %{client: c} do
    assert {:ok, _} = Jobs.list(c, limit: 2)
    assert_receive {:request, request}
    assert request.query == "limit=2"
  end
end
