defmodule OpenAi.Conversations do
  @moduledoc "Client functions for Responses API conversations and their items."

  alias OpenAi.Client

  @doc "Creates a conversation. `POST /conversations`"
  @spec create(Client.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def create(%Client{} = client, body \\ %{}, options \\ []) when is_map(body) do
    Client.request(client, :post, "/conversations", Keyword.put(options, :body, body))
  end

  @doc "Retrieves a conversation. `GET /conversations/{conversation_id}`"
  @spec retrieve(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def retrieve(%Client{} = client, conversation_id, options \\ []) do
    Client.request(client, :get, path(conversation_id), options)
  end

  @doc "Updates a conversation. `POST /conversations/{conversation_id}`"
  @spec update(Client.t(), String.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def update(%Client{} = client, conversation_id, body, options \\ []) when is_map(body) do
    Client.request(client, :post, path(conversation_id), Keyword.put(options, :body, body))
  end

  @doc "Deletes a conversation. `DELETE /conversations/{conversation_id}`"
  @spec delete(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def delete(%Client{} = client, conversation_id, options \\ []) do
    Client.request(client, :delete, path(conversation_id), options)
  end

  @doc "Adds items to a conversation. `POST /conversations/{conversation_id}/items`"
  @spec create_items(Client.t(), String.t(), list() | map(), map() | keyword(), keyword()) ::
          {:ok, map()} | {:error, OpenAi.Error.t()}
  def create_items(%Client{} = client, conversation_id, items, query \\ [], options \\ []) do
    body = if is_map(items), do: items, else: %{items: items}

    Client.request(
      client,
      :post,
      items_path(conversation_id),
      options |> Keyword.put(:body, body) |> Keyword.put(:query, query)
    )
  end

  @doc "Lists conversation items. `GET /conversations/{conversation_id}/items`"
  @spec list_items(Client.t(), String.t(), map() | keyword(), keyword()) ::
          {:ok, map()} | {:error, OpenAi.Error.t()}
  def list_items(%Client{} = client, conversation_id, query \\ [], options \\ []) do
    Client.request(
      client,
      :get,
      items_path(conversation_id),
      Keyword.put(options, :query, query)
    )
  end

  @doc "Retrieves a conversation item. `GET /conversations/{conversation_id}/items/{item_id}`"
  @spec retrieve_item(Client.t(), String.t(), String.t(), map() | keyword(), keyword()) ::
          {:ok, map()} | {:error, OpenAi.Error.t()}
  def retrieve_item(%Client{} = client, conversation_id, item_id, query \\ [], options \\ []) do
    Client.request(
      client,
      :get,
      item_path(conversation_id, item_id),
      Keyword.put(options, :query, query)
    )
  end

  @doc "Deletes a conversation item. `DELETE /conversations/{conversation_id}/items/{item_id}`"
  @spec delete_item(Client.t(), String.t(), String.t(), keyword()) ::
          {:ok, map()} | {:error, OpenAi.Error.t()}
  def delete_item(%Client{} = client, conversation_id, item_id, options \\ []) do
    Client.request(client, :delete, item_path(conversation_id, item_id), options)
  end

  defp path(conversation_id), do: "/conversations/" <> Client.path_segment(conversation_id)
  defp items_path(conversation_id), do: path(conversation_id) <> "/items"

  defp item_path(conversation_id, item_id),
    do: items_path(conversation_id) <> "/" <> Client.path_segment(item_id)
end
