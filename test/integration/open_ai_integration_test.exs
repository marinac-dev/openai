defmodule OpenAi.IntegrationTest do
  use ExUnit.Case, async: false

  alias OpenAi.{Client, Models, Responses}

  @moduletag :integration

  setup_all do
    api_key =
      System.get_env("OPENAI_API_KEY") ||
        raise "OPENAI_API_KEY is required for integration tests"

    client =
      Client.new(
        api_key: api_key,
        receive_timeout: 120_000
      )

    model = System.get_env("OPENAI_INTEGRATION_MODEL") || "gpt-4o-mini"

    {:ok, client: client, model: model}
  end

  test "lists models over the configured API endpoint", %{client: client} do
    assert {:ok, %{"object" => "list", "data" => models}} = Models.list(client)
    assert is_list(models)
    assert models != []
  end

  test "creates a response", %{client: client, model: model} do
    assert {:ok, %{"id" => "resp_" <> _, "status" => status} = response} =
             Responses.create(client, %{
               model: model,
               input: "Reply with exactly: integration-ok",
               store: false
             })

    assert status == "completed"
    assert Responses.output_text(response) =~ "integration-ok"
  end

  test "streams response events", %{client: client, model: model} do
    owner = self()

    assert {:ok, %{status: 200}} =
             Responses.stream(
               client,
               %{model: model, input: "Reply with exactly: stream-ok", store: false},
               &send(owner, {:openai_event, &1})
             )

    events = receive_events([])

    assert Enum.any?(events, &(&1["type"] == "response.output_text.delta"))
    assert Enum.any?(events, &(&1["type"] == "response.completed"))
  end

  defp receive_events(events) do
    receive do
      {:openai_event, event} -> receive_events([event | events])
    after
      0 -> Enum.reverse(events)
    end
  end
end
