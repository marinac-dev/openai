defmodule OpenAi.ChatKit.Threads do
  @moduledoc "Client functions for ChatKit threads."

  alias OpenAi.Client

  @doc "Lists ChatKit threads. `GET /chatkit/threads`"
  @spec list(Client.t(), map() | keyword(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def list(%Client{} = client, query \\ [], options \\ []) do
    Client.request(client, :get, "/chatkit/threads", Keyword.put(options, :query, query))
  end

  @doc "Retrieves a ChatKit thread. `GET /chatkit/threads/{thread_id}`"
  @spec retrieve(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def retrieve(%Client{} = client, thread_id, options \\ []) do
    Client.request(client, :get, path(thread_id), options)
  end

  @doc "Deletes a ChatKit thread. `DELETE /chatkit/threads/{thread_id}`"
  @spec delete(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def delete(%Client{} = client, thread_id, options \\ []) do
    Client.request(client, :delete, path(thread_id), options)
  end

  @doc "Lists items in a ChatKit thread. `GET /chatkit/threads/{thread_id}/items`"
  @spec list_items(Client.t(), String.t(), map() | keyword(), keyword()) ::
          {:ok, map()} | {:error, OpenAi.Error.t()}
  def list_items(%Client{} = client, thread_id, query \\ [], options \\ []) do
    Client.request(client, :get, path(thread_id) <> "/items", Keyword.put(options, :query, query))
  end

  defp path(thread_id), do: "/chatkit/threads/#{Client.path_segment(thread_id)}"
end
