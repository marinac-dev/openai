defmodule OpenAi.Threads.Runs do
  @moduledoc """
  Thread runs. Deprecated by OpenAI in favour of the Responses API.
  """

  alias OpenAi.Client

  @doc "Lists runs of a thread. `GET /threads/{thread_id}/runs`"
  @spec list(Client.t(), String.t(), map() | keyword(), keyword()) ::
          {:ok, map()} | {:error, OpenAi.Error.t()}
  def list(%Client{} = client, thread_id, query \\ [], options \\ []) do
    Client.request(client, :get, base(thread_id), Keyword.put(options, :query, query))
  end

  @doc """
  Creates a run. `POST /threads/{thread_id}/runs`

  Pass `query: [include: ["step_details.tool_calls[*].file_search.results[*].content"]]` in `options` for `include[]`.
  """
  @spec create(Client.t(), String.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def create(%Client{} = client, thread_id, body, options \\ []) when is_map(body) do
    Client.request(client, :post, base(thread_id), Keyword.put(options, :body, body))
  end

  @doc "Creates a run, streaming run events to `on_event`."
  @spec stream_create(Client.t(), String.t(), map(), (map() -> term()), keyword()) ::
          {:ok, OpenAi.Response.t()} | {:error, OpenAi.Error.t()}
  def stream_create(%Client{} = client, thread_id, body, on_event, options \\ []) when is_map(body) do
    Client.stream(client, :post, base(thread_id), on_event, Keyword.put(options, :body, put_stream(body)))
  end

  @doc "Retrieves a run. `GET /threads/{thread_id}/runs/{run_id}`"
  @spec retrieve(Client.t(), String.t(), String.t(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def retrieve(%Client{} = client, thread_id, run_id, options \\ []) do
    Client.request(client, :get, path(thread_id, run_id), options)
  end

  @doc "Modifies a run. `POST /threads/{thread_id}/runs/{run_id}`"
  @spec update(Client.t(), String.t(), String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, OpenAi.Error.t()}
  def update(%Client{} = client, thread_id, run_id, body, options \\ []) when is_map(body) do
    Client.request(client, :post, path(thread_id, run_id), Keyword.put(options, :body, body))
  end

  @doc "Cancels a run. `POST /threads/{thread_id}/runs/{run_id}/cancel`"
  @spec cancel(Client.t(), String.t(), String.t(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def cancel(%Client{} = client, thread_id, run_id, options \\ []) do
    Client.request(client, :post, path(thread_id, run_id) <> "/cancel", options)
  end

  @doc "Submits tool outputs to a run. `POST /threads/{thread_id}/runs/{run_id}/submit_tool_outputs`"
  @spec submit_tool_outputs(Client.t(), String.t(), String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, OpenAi.Error.t()}
  def submit_tool_outputs(%Client{} = client, thread_id, run_id, body, options \\ []) when is_map(body) do
    Client.request(client, :post, submit_path(thread_id, run_id), Keyword.put(options, :body, body))
  end

  @doc "Submits tool outputs to a run, streaming run events to `on_event`."
  @spec stream_submit_tool_outputs(Client.t(), String.t(), String.t(), map(), (map() -> term()), keyword()) ::
          {:ok, OpenAi.Response.t()} | {:error, OpenAi.Error.t()}
  def stream_submit_tool_outputs(%Client{} = client, thread_id, run_id, body, on_event, options \\ [])
      when is_map(body) do
    options = Keyword.put(options, :body, put_stream(body))
    Client.stream(client, :post, submit_path(thread_id, run_id), on_event, options)
  end

  defp base(thread_id), do: "/threads/" <> Client.path_segment(thread_id) <> "/runs"
  defp path(thread_id, run_id), do: base(thread_id) <> "/" <> Client.path_segment(run_id)
  defp submit_path(thread_id, run_id), do: path(thread_id, run_id) <> "/submit_tool_outputs"

  defp put_stream(body) do
    if Map.has_key?(body, "stream"), do: Map.put(body, "stream", true), else: Map.put(body, :stream, true)
  end
end
