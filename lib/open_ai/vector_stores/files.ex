defmodule OpenAi.VectorStores.Files do
  @moduledoc "Client functions for files attached to vector stores."

  alias OpenAi.Client

  @type result :: {:ok, map()} | {:error, OpenAi.Error.t()}

  @doc "Lists vector store files. `GET /vector_stores/{vector_store_id}/files`"
  @spec list(Client.t(), String.t(), map() | keyword(), keyword()) :: result()
  def list(%Client{} = client, vector_store_id, query \\ [], options \\ []) do
    Client.request(client, :get, files_path(vector_store_id), Keyword.put(options, :query, query))
  end

  @doc "Creates a vector store file. `POST /vector_stores/{vector_store_id}/files`"
  @spec create(Client.t(), String.t(), map(), keyword()) :: result()
  def create(%Client{} = client, vector_store_id, body, options \\ []) when is_map(body) do
    Client.request(client, :post, files_path(vector_store_id), Keyword.put(options, :body, body))
  end

  @doc "Retrieves a vector store file. `GET /vector_stores/{vector_store_id}/files/{file_id}`"
  @spec retrieve(Client.t(), String.t(), String.t(), keyword()) :: result()
  def retrieve(%Client{} = client, vector_store_id, file_id, options \\ []) do
    Client.request(client, :get, file_path(vector_store_id, file_id), options)
  end

  @doc "Updates vector store file attributes. `POST /vector_stores/{vector_store_id}/files/{file_id}`"
  @spec update(Client.t(), String.t(), String.t(), map(), keyword()) :: result()
  def update(%Client{} = client, vector_store_id, file_id, body, options \\ []) when is_map(body) do
    Client.request(client, :post, file_path(vector_store_id, file_id), Keyword.put(options, :body, body))
  end

  @doc "Deletes a vector store file. `DELETE /vector_stores/{vector_store_id}/files/{file_id}`"
  @spec delete(Client.t(), String.t(), String.t(), keyword()) :: result()
  def delete(%Client{} = client, vector_store_id, file_id, options \\ []) do
    Client.request(client, :delete, file_path(vector_store_id, file_id), options)
  end

  @doc "Retrieves parsed vector store file content. `GET /vector_stores/{vector_store_id}/files/{file_id}/content`"
  @spec content(Client.t(), String.t(), String.t(), keyword()) :: result()
  def content(%Client{} = client, vector_store_id, file_id, options \\ []) do
    Client.request(client, :get, file_path(vector_store_id, file_id) <> "/content", options)
  end

  defp files_path(vector_store_id), do: "/vector_stores/" <> Client.path_segment(vector_store_id) <> "/files"
  defp file_path(vector_store_id, file_id), do: files_path(vector_store_id) <> "/" <> Client.path_segment(file_id)
end
