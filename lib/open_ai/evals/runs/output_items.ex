defmodule OpenAi.Evals.Runs.OutputItems do
  @moduledoc "Client functions for eval run output items."

  alias OpenAi.Client

  @type result :: {:ok, map()} | {:error, OpenAi.Error.t()}

  @doc "Lists eval run output items. `GET /evals/{eval_id}/runs/{run_id}/output_items`"
  @spec list(Client.t(), String.t(), String.t(), map() | keyword(), keyword()) :: result()
  def list(%Client{} = client, eval_id, run_id, query \\ [], options \\ []) do
    Client.request(client, :get, base(eval_id, run_id), Keyword.put(options, :query, query))
  end

  @doc "Retrieves an eval run output item. `GET /evals/{eval_id}/runs/{run_id}/output_items/{output_item_id}`"
  @spec retrieve(Client.t(), String.t(), String.t(), String.t(), keyword()) :: result()
  def retrieve(%Client{} = client, eval_id, run_id, output_item_id, options \\ []) do
    Client.request(client, :get, base(eval_id, run_id) <> "/" <> Client.path_segment(output_item_id), options)
  end

  defp base(eval_id, run_id) do
    "/evals/" <> Client.path_segment(eval_id) <> "/runs/" <> Client.path_segment(run_id) <> "/output_items"
  end
end
