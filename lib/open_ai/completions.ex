defmodule OpenAi.Completions do
  @moduledoc "Client functions for the legacy Completions API."

  alias OpenAi.Client

  @doc "Creates a text completion. `POST /completions`"
  @spec create(Client.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def create(%Client{} = client, body, options \\ []) when is_map(body) do
    Client.request(client, :post, "/completions", Keyword.put(options, :body, body))
  end

  @doc """
  Creates a streamed text completion, invoking `on_event` with each decoded event.

  Forces `stream: true` in the request body.
  """
  @spec stream(Client.t(), map(), (map() -> term()), keyword()) ::
          {:ok, OpenAi.Response.t()} | {:error, OpenAi.Error.t()}
  def stream(%Client{} = client, body, on_event, options \\ []) when is_map(body) do
    Client.stream(client, :post, "/completions", on_event, Keyword.put(options, :body, put_stream(body)))
  end

  defp put_stream(body) do
    if Map.has_key?(body, "stream") do
      Map.put(body, "stream", true)
    else
      Map.put(body, :stream, true)
    end
  end
end
