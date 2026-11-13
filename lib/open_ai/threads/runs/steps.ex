defmodule OpenAi.Threads.Runs.Steps do
  @moduledoc """
  Thread run steps. Deprecated by OpenAI in favour of the Responses API.
  """

  alias OpenAi.Client

  @doc "Lists steps of a run. `GET /threads/{thread_id}/runs/{run_id}/steps`"
  @spec list(Client.t(), String.t(), String.t(), map() | keyword(), keyword()) ::
          {:ok, map()} | {:error, OpenAi.Error.t()}
  def list(%Client{} = client, thread_id, run_id, query \\ [], options \\ []) do
    Client.request(client, :get, base(thread_id, run_id), Keyword.put(options, :query, query))
  end

  @doc "Retrieves a run step. `GET /threads/{thread_id}/runs/{run_id}/steps/{step_id}`"
  @spec retrieve(Client.t(), String.t(), String.t(), String.t(), map() | keyword(), keyword()) ::
          {:ok, map()} | {:error, OpenAi.Error.t()}
  def retrieve(%Client{} = client, thread_id, run_id, step_id, query \\ [], options \\ []) do
    path = base(thread_id, run_id) <> "/" <> Client.path_segment(step_id)
    Client.request(client, :get, path, Keyword.put(options, :query, query))
  end

  defp base(thread_id, run_id) do
    "/threads/" <> Client.path_segment(thread_id) <> "/runs/" <> Client.path_segment(run_id) <> "/steps"
  end
end
