defmodule OpenAi.Threads.Messages do
  @moduledoc """
  Thread messages. Deprecated by OpenAI in favour of the Responses API.
  """

  alias OpenAi.Client

  @doc "Lists messages of a thread. `GET /threads/{thread_id}/messages`"
  @spec list(Client.t(), String.t(), map() | keyword(), keyword()) ::
          {:ok, map()} | {:error, OpenAi.Error.t()}
  def list(%Client{} = client, thread_id, query \\ [], options \\ []) do
    Client.request(client, :get, base(thread_id), Keyword.put(options, :query, query))
  end

  @doc "Creates a message in a thread. `POST /threads/{thread_id}/messages`"
  @spec create(Client.t(), String.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def create(%Client{} = client, thread_id, body, options \\ []) when is_map(body) do
    Client.request(client, :post, base(thread_id), Keyword.put(options, :body, body))
  end

  @doc "Retrieves a message. `GET /threads/{thread_id}/messages/{message_id}`"
  @spec retrieve(Client.t(), String.t(), String.t(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def retrieve(%Client{} = client, thread_id, message_id, options \\ []) do
    Client.request(client, :get, path(thread_id, message_id), options)
  end

  @doc "Modifies a message. `POST /threads/{thread_id}/messages/{message_id}`"
  @spec update(Client.t(), String.t(), String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, OpenAi.Error.t()}
  def update(%Client{} = client, thread_id, message_id, body, options \\ []) when is_map(body) do
    Client.request(client, :post, path(thread_id, message_id), Keyword.put(options, :body, body))
  end

  @doc "Deletes a message. `DELETE /threads/{thread_id}/messages/{message_id}`"
  @spec delete(Client.t(), String.t(), String.t(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def delete(%Client{} = client, thread_id, message_id, options \\ []) do
    Client.request(client, :delete, path(thread_id, message_id), options)
  end

  defp base(thread_id), do: "/threads/" <> Client.path_segment(thread_id) <> "/messages"
  defp path(thread_id, message_id), do: base(thread_id) <> "/" <> Client.path_segment(message_id)
end
