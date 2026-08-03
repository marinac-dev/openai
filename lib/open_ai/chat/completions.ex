defmodule OpenAi.Chat.Completions do
  @moduledoc "Client functions for the Chat Completions API."

  alias OpenAi.Client

  @spec create(Client.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def create(%Client{} = client, body, options \\ []) when is_map(body) do
    Client.request(client, :post, "/chat/completions", Keyword.put(options, :body, body))
  end

  @spec stream(Client.t(), map(), (map() -> term()), keyword()) ::
          {:ok, OpenAi.Response.t()} | {:error, OpenAi.Error.t()}
  def stream(%Client{} = client, body, on_event, options \\ []) when is_map(body) do
    Client.stream(
      client,
      :post,
      "/chat/completions",
      on_event,
      Keyword.put(options, :body, put_stream(body))
    )
  end

  @spec list(Client.t(), map() | keyword(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def list(%Client{} = client, query \\ [], options \\ []) do
    Client.request(client, :get, "/chat/completions", Keyword.put(options, :query, query))
  end

  @spec retrieve(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def retrieve(%Client{} = client, completion_id, options \\ []) do
    Client.request(client, :get, path(completion_id), options)
  end

  @spec update(Client.t(), String.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def update(%Client{} = client, completion_id, body, options \\ []) when is_map(body) do
    Client.request(client, :post, path(completion_id), Keyword.put(options, :body, body))
  end

  @spec delete(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def delete(%Client{} = client, completion_id, options \\ []) do
    Client.request(client, :delete, path(completion_id), options)
  end

  @spec list_messages(Client.t(), String.t(), map() | keyword(), keyword()) ::
          {:ok, map()} | {:error, OpenAi.Error.t()}
  def list_messages(%Client{} = client, completion_id, query \\ [], options \\ []) do
    Client.request(
      client,
      :get,
      path(completion_id) <> "/messages",
      Keyword.put(options, :query, query)
    )
  end

  defp path(completion_id), do: "/chat/completions/" <> Client.path_segment(completion_id)

  defp put_stream(body) do
    if Map.has_key?(body, "stream") do
      Map.put(body, "stream", true)
    else
      Map.put(body, :stream, true)
    end
  end
end
