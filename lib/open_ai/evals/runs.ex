defmodule OpenAi.Evals.Runs do
  @moduledoc "Client functions for eval runs."

  alias OpenAi.Client

  @type result :: {:ok, map()} | {:error, OpenAi.Error.t()}

  @doc "Lists eval runs. `GET /evals/{eval_id}/runs`"
  @spec list(Client.t(), String.t(), map() | keyword(), keyword()) :: result()
  def list(%Client{} = client, eval_id, query \\ [], options \\ []) do
    Client.request(client, :get, base(eval_id), Keyword.put(options, :query, query))
  end

  @doc "Creates an eval run. `POST /evals/{eval_id}/runs`"
  @spec create(Client.t(), String.t(), map(), keyword()) :: result()
  def create(%Client{} = client, eval_id, body, options \\ []) when is_map(body) do
    Client.request(client, :post, base(eval_id), Keyword.put(options, :body, body))
  end

  @doc "Retrieves an eval run. `GET /evals/{eval_id}/runs/{run_id}`"
  @spec retrieve(Client.t(), String.t(), String.t(), keyword()) :: result()
  def retrieve(%Client{} = client, eval_id, run_id, options \\ []) do
    Client.request(client, :get, path(eval_id, run_id), options)
  end

  @doc "Cancels an eval run. `POST /evals/{eval_id}/runs/{run_id}`"
  @spec cancel(Client.t(), String.t(), String.t(), keyword()) :: result()
  def cancel(%Client{} = client, eval_id, run_id, options \\ []) do
    Client.request(client, :post, path(eval_id, run_id), options)
  end

  @doc "Deletes an eval run. `DELETE /evals/{eval_id}/runs/{run_id}`"
  @spec delete(Client.t(), String.t(), String.t(), keyword()) :: result()
  def delete(%Client{} = client, eval_id, run_id, options \\ []) do
    Client.request(client, :delete, path(eval_id, run_id), options)
  end

  defp base(eval_id), do: "/evals/" <> Client.path_segment(eval_id) <> "/runs"
  defp path(eval_id, run_id), do: base(eval_id) <> "/" <> Client.path_segment(run_id)
end
