defmodule OpenAi.VectorStores do
  @moduledoc "Client functions for vector stores and vector store search."

  alias OpenAi.Client

  @type result :: {:ok, map()} | {:error, OpenAi.Error.t()}

  @doc "Lists vector stores. `GET /vector_stores`"
  @spec list(Client.t(), map() | keyword(), keyword()) :: result()
  def list(%Client{} = client, query \\ [], options \\ []) do
    Client.request(client, :get, "/vector_stores", Keyword.put(options, :query, query))
  end

  @doc "Creates a vector store. `POST /vector_stores`"
  @spec create(Client.t(), map(), keyword()) :: result()
  def create(%Client{} = client, body \\ %{}, options \\ []) when is_map(body) do
    Client.request(client, :post, "/vector_stores", Keyword.put(options, :body, body))
  end

  @doc "Retrieves a vector store. `GET /vector_stores/{vector_store_id}`"
  @spec retrieve(Client.t(), String.t(), keyword()) :: result()
  def retrieve(%Client{} = client, vector_store_id, options \\ []) do
    Client.request(client, :get, path(vector_store_id), options)
  end

  @doc "Updates a vector store. `POST /vector_stores/{vector_store_id}`"
  @spec update(Client.t(), String.t(), map(), keyword()) :: result()
  def update(%Client{} = client, vector_store_id, body, options \\ []) when is_map(body) do
    Client.request(client, :post, path(vector_store_id), Keyword.put(options, :body, body))
  end

  @doc "Deletes a vector store. `DELETE /vector_stores/{vector_store_id}`"
  @spec delete(Client.t(), String.t(), keyword()) :: result()
  def delete(%Client{} = client, vector_store_id, options \\ []) do
    Client.request(client, :delete, path(vector_store_id), options)
  end

  @doc "Searches a vector store. `POST /vector_stores/{vector_store_id}/search`"
  @spec search(Client.t(), String.t(), map(), keyword()) :: result()
  def search(%Client{} = client, vector_store_id, body, options \\ []) when is_map(body) do
    Client.request(client, :post, path(vector_store_id) <> "/search", Keyword.put(options, :body, body))
  end

  defp path(vector_store_id), do: "/vector_stores/" <> Client.path_segment(vector_store_id)
end
