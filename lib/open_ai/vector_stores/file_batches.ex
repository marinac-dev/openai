defmodule OpenAi.VectorStores.FileBatches do
  @moduledoc "Client functions for vector store file batches."

  alias OpenAi.Client

  @type result :: {:ok, map()} | {:error, OpenAi.Error.t()}

  @doc "Creates a vector store file batch. `POST /vector_stores/{vector_store_id}/file_batches`"
  @spec create(Client.t(), String.t(), map(), keyword()) :: result()
  def create(%Client{} = client, vector_store_id, body, options \\ []) when is_map(body) do
    Client.request(client, :post, batches_path(vector_store_id), Keyword.put(options, :body, body))
  end

  @doc "Retrieves a vector store file batch. `GET /vector_stores/{vector_store_id}/file_batches/{batch_id}`"
  @spec retrieve(Client.t(), String.t(), String.t(), keyword()) :: result()
  def retrieve(%Client{} = client, vector_store_id, batch_id, options \\ []) do
    Client.request(client, :get, batch_path(vector_store_id, batch_id), options)
  end

  @doc "Cancels a vector store file batch. `POST /vector_stores/{vector_store_id}/file_batches/{batch_id}/cancel`"
  @spec cancel(Client.t(), String.t(), String.t(), keyword()) :: result()
  def cancel(%Client{} = client, vector_store_id, batch_id, options \\ []) do
    Client.request(client, :post, batch_path(vector_store_id, batch_id) <> "/cancel", options)
  end

  @doc "Lists files in a vector store file batch. `GET /vector_stores/{vector_store_id}/file_batches/{batch_id}/files`"
  @spec list_files(Client.t(), String.t(), String.t(), map() | keyword(), keyword()) :: result()
  def list_files(%Client{} = client, vector_store_id, batch_id, query \\ [], options \\ []) do
    Client.request(
      client,
      :get,
      batch_path(vector_store_id, batch_id) <> "/files",
      Keyword.put(options, :query, query)
    )
  end

  defp batches_path(vector_store_id) do
    "/vector_stores/" <> Client.path_segment(vector_store_id) <> "/file_batches"
  end

  defp batch_path(vector_store_id, batch_id), do: batches_path(vector_store_id) <> "/" <> Client.path_segment(batch_id)
end
