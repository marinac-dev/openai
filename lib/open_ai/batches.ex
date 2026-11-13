defmodule OpenAi.Batches do
  @moduledoc "Client functions for the Batch API."

  alias OpenAi.Client

  @doc "Creates a batch. `POST /batches`"
  @spec create(Client.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def create(%Client{} = client, body, options \\ []) when is_map(body) do
    Client.request(client, :post, "/batches", Keyword.put(options, :body, body))
  end

  @doc "Lists batches. `GET /batches`"
  @spec list(Client.t(), map() | keyword(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def list(%Client{} = client, query \\ [], options \\ []) do
    Client.request(client, :get, "/batches", Keyword.put(options, :query, query))
  end

  @doc "Retrieves a batch. `GET /batches/{batch_id}`"
  @spec retrieve(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def retrieve(%Client{} = client, batch_id, options \\ []) do
    Client.request(client, :get, path(batch_id), options)
  end

  @doc "Cancels an in-progress batch. `POST /batches/{batch_id}/cancel`"
  @spec cancel(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def cancel(%Client{} = client, batch_id, options \\ []) do
    Client.request(client, :post, path(batch_id) <> "/cancel", options)
  end

  defp path(batch_id), do: "/batches/#{Client.path_segment(batch_id)}"
end
