defmodule OpenAi.Responses do
  @moduledoc "Client functions for the Responses API."

  alias OpenAi.Client

  @spec create(Client.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def create(%Client{} = client, body, options \\ []) when is_map(body) do
    Client.request(client, :post, "/responses", Keyword.put(options, :body, body))
  end

  @spec stream(Client.t(), map(), (map() -> term()), keyword()) ::
          {:ok, OpenAi.Response.t()} | {:error, OpenAi.Error.t()}
  def stream(%Client{} = client, body, on_event, options \\ []) when is_map(body) do
    Client.stream(
      client,
      :post,
      "/responses",
      on_event,
      Keyword.put(options, :body, put_stream(body))
    )
  end

  @spec retrieve(Client.t(), String.t(), map() | keyword(), keyword()) ::
          {:ok, map()} | {:error, OpenAi.Error.t()}
  def retrieve(%Client{} = client, response_id, query \\ [], options \\ []) do
    Client.request(client, :get, path(response_id), Keyword.put(options, :query, query))
  end

  @spec delete(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def delete(%Client{} = client, response_id, options \\ []) do
    Client.request(client, :delete, path(response_id), options)
  end

  @spec cancel(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def cancel(%Client{} = client, response_id, options \\ []) do
    Client.request(client, :post, path(response_id) <> "/cancel", options)
  end

  @spec list_input_items(Client.t(), String.t(), map() | keyword(), keyword()) ::
          {:ok, map()} | {:error, OpenAi.Error.t()}
  def list_input_items(%Client{} = client, response_id, query \\ [], options \\ []) do
    Client.request(
      client,
      :get,
      path(response_id) <> "/input_items",
      Keyword.put(options, :query, query)
    )
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
