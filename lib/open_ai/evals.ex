defmodule OpenAi.Evals do
  @moduledoc "Client functions for evals."

  alias OpenAi.Client

  @type result :: {:ok, map()} | {:error, OpenAi.Error.t()}

  @doc "Lists evals. `GET /evals`"
  @spec list(Client.t(), map() | keyword(), keyword()) :: result()
  def list(%Client{} = client, query \\ [], options \\ []) do
    Client.request(client, :get, "/evals", Keyword.put(options, :query, query))
  end

  @doc "Creates an eval. `POST /evals`"
  @spec create(Client.t(), map(), keyword()) :: result()
  def create(%Client{} = client, body, options \\ []) when is_map(body) do
    Client.request(client, :post, "/evals", Keyword.put(options, :body, body))
  end

  @doc "Retrieves an eval. `GET /evals/{eval_id}`"
  @spec retrieve(Client.t(), String.t(), keyword()) :: result()
  def retrieve(%Client{} = client, eval_id, options \\ []) do
    Client.request(client, :get, path(eval_id), options)
  end

  @doc "Updates an eval. `POST /evals/{eval_id}`"
  @spec update(Client.t(), String.t(), map(), keyword()) :: result()
  def update(%Client{} = client, eval_id, body, options \\ []) when is_map(body) do
    Client.request(client, :post, path(eval_id), Keyword.put(options, :body, body))
  end

  @doc "Deletes an eval. `DELETE /evals/{eval_id}`"
  @spec delete(Client.t(), String.t(), keyword()) :: result()
  def delete(%Client{} = client, eval_id, options \\ []) do
    Client.request(client, :delete, path(eval_id), options)
  end

  defp path(eval_id), do: "/evals/" <> Client.path_segment(eval_id)
end
