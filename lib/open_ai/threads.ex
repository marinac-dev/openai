defmodule OpenAi.Threads do
  @moduledoc """
  Threads. Deprecated by OpenAI in favour of the Responses API.
  """

  alias OpenAi.Client

  @doc "Creates a thread. `POST /threads`"
  @spec create(Client.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def create(%Client{} = client, body \\ %{}, options \\ []) when is_map(body) do
    Client.request(client, :post, "/threads", Keyword.put(options, :body, body))
  end

  @doc "Creates a thread and runs it in one request. `POST /threads/runs`"
  @spec create_and_run(Client.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def create_and_run(%Client{} = client, body, options \\ []) when is_map(body) do
    Client.request(client, :post, "/threads/runs", Keyword.put(options, :body, body))
  end

  @doc "Creates a thread and run, streaming run events to `on_event`."
  @spec stream_create_and_run(Client.t(), map(), (map() -> term()), keyword()) ::
          {:ok, OpenAi.Response.t()} | {:error, OpenAi.Error.t()}
  def stream_create_and_run(%Client{} = client, body, on_event, options \\ []) when is_map(body) do
    Client.stream(client, :post, "/threads/runs", on_event, Keyword.put(options, :body, put_stream(body)))
  end

  @doc "Retrieves a thread. `GET /threads/{thread_id}`"
  @spec retrieve(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def retrieve(%Client{} = client, thread_id, options \\ []) do
    Client.request(client, :get, path(thread_id), options)
  end

  @doc "Modifies a thread. `POST /threads/{thread_id}`"
  @spec update(Client.t(), String.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def update(%Client{} = client, thread_id, body, options \\ []) when is_map(body) do
    Client.request(client, :post, path(thread_id), Keyword.put(options, :body, body))
  end

  @doc "Deletes a thread. `DELETE /threads/{thread_id}`"
  @spec delete(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def delete(%Client{} = client, thread_id, options \\ []) do
    Client.request(client, :delete, path(thread_id), options)
  end

  defp path(thread_id), do: "/threads/" <> Client.path_segment(thread_id)

  defp put_stream(body) do
    if Map.has_key?(body, "stream"), do: Map.put(body, "stream", true), else: Map.put(body, :stream, true)
  end
end
