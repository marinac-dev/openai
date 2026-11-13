defmodule OpenAi.Responses do
  @moduledoc """
  Client functions for the Responses API.

  Every function accepts a `:beta` option that targets the beta variant of the
  endpoint (`?beta=true`). Pass `beta: true`, or a list of beta feature names to
  also send them in the `OpenAI-Beta` header, e.g. `beta: ["feature-2026-01-01"]`.
  """

  alias OpenAi.Client

  @doc "Creates a model response. `POST /responses`"
  @spec create(Client.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def create(%Client{} = client, body, options \\ []) when is_map(body) do
    request(client, :post, "/responses", Keyword.put(options, :body, body))
  end

  @doc "Creates a model response and streams its events to `on_event`."
  @spec stream(Client.t(), map(), (map() -> term()), keyword()) ::
          {:ok, OpenAi.Response.t()} | {:error, OpenAi.Error.t()}
  def stream(%Client{} = client, body, on_event, options \\ []) when is_map(body) do
    options = options |> Keyword.put(:body, put_stream(body)) |> beta_options()
    Client.stream(client, :post, "/responses", on_event, options)
  end

  @doc "Retrieves a model response. `GET /responses/{response_id}`"
  @spec retrieve(Client.t(), String.t(), map() | keyword(), keyword()) ::
          {:ok, map()} | {:error, OpenAi.Error.t()}
  def retrieve(%Client{} = client, response_id, query \\ [], options \\ []) do
    request(client, :get, path(response_id), Keyword.put(options, :query, query))
  end

  @doc "Streams a background response from the beginning or from `starting_after`."
  @spec stream_retrieve(Client.t(), String.t(), (map() -> term()), map() | keyword(), keyword()) ::
          {:ok, OpenAi.Response.t()} | {:error, OpenAi.Error.t()}
  def stream_retrieve(%Client{} = client, response_id, on_event, query \\ [], options \\ []) do
    query = put_query(query, :stream, true)
    options = options |> Keyword.put(:query, query) |> beta_options()
    Client.stream(client, :get, path(response_id), on_event, options)
  end

  @doc "Deletes a model response. `DELETE /responses/{response_id}`"
  @spec delete(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def delete(%Client{} = client, response_id, options \\ []) do
    request(client, :delete, path(response_id), options)
  end

  @doc "Cancels a background model response. `POST /responses/{response_id}/cancel`"
  @spec cancel(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def cancel(%Client{} = client, response_id, options \\ []) do
    request(client, :post, path(response_id) <> "/cancel", options)
  end

  @doc "Lists the input items of a model response. `GET /responses/{response_id}/input_items`"
  @spec list_input_items(Client.t(), String.t(), map() | keyword(), keyword()) ::
          {:ok, map()} | {:error, OpenAi.Error.t()}
  def list_input_items(%Client{} = client, response_id, query \\ [], options \\ []) do
    request(client, :get, path(response_id) <> "/input_items", Keyword.put(options, :query, query))
  end

  @doc "Counts the input tokens a `create/3` request with the same body would use. `POST /responses/input_tokens`"
  @spec input_tokens(Client.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def input_tokens(%Client{} = client, body, options \\ []) when is_map(body) do
    request(client, :post, "/responses/input_tokens", Keyword.put(options, :body, body))
  end

  @doc "Compacts a conversation into a smaller set of input items. `POST /responses/compact`"
  @spec compact(Client.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def compact(%Client{} = client, body, options \\ []) when is_map(body) do
    request(client, :post, "/responses/compact", Keyword.put(options, :body, body))
  end

  @doc "Collects all `output_text` values from a response in output order."
  @spec output_text(map()) :: String.t()
  def output_text(response) when is_map(response) do
    response
    |> field(:output, [])
    |> Enum.flat_map(&field(&1, :content, []))
    |> Enum.filter(&(field(&1, :type) == "output_text"))
    |> Enum.map_join(&field(&1, :text, ""))
  end

  defp request(client, method, path, options) do
    Client.request(client, method, path, beta_options(options))
  end

  defp beta_options(options) do
    case Keyword.pop(options, :beta) do
      {beta, options} when beta in [nil, false] ->
        options

      {true, options} ->
        Keyword.update(options, :query, [beta: true], &put_query(&1, :beta, true))

      {betas, options} when is_list(betas) ->
        options
        |> Keyword.update(:query, [beta: true], &put_query(&1, :beta, true))
        |> Keyword.update(:headers, [{"openai-beta", Enum.join(betas, ",")}], fn headers ->
          Enum.to_list(headers) ++ [{"openai-beta", Enum.join(betas, ",")}]
        end)
    end
  end

  defp put_query(query, key, value) when is_map(query), do: Map.put(query, key, value)
  defp put_query(query, key, value) when is_list(query), do: Keyword.put(query, key, value)

  defp path(response_id), do: "/responses/" <> Client.path_segment(response_id)

  defp put_stream(body) do
    if Map.has_key?(body, "stream") do
      Map.put(body, "stream", true)
    else
      Map.put(body, :stream, true)
    end
  end

  defp field(map, key, default \\ nil) do
    Map.get(map, key, Map.get(map, Atom.to_string(key), default))
  end
end
