defmodule OpenAi.Core.Response.ChatCompletion do
  @moduledoc """
  Documentation for `ChatCompletion` response.
  """
  alias OpenAi.Utils.Parser

  @behaviour OpenAi.Core.Response

  @enforce_keys [:id, :object, :created_at, :choices, :usage]
  defstruct [:id, :object, :created_at, :choices, :usage, :model]

  @type t :: %__MODULE__{
          id: String.t(),
          object: String.t(),
          # NOTE: Returned field is called `created`, but we rename it to `created_at` for consistency
          created_at: DateTime.t(),
          choices: list(map()),
          usage: list(map()) | nil,
          model: String.t()
        }

  # * For parsing streaming SSE responses
  @impl true
  def parse({:ok, %{body: body, type: :stream}}) do
    resp = Parser.parse_chat_sse(body)
    struct(__MODULE__, resp)
  end

  # * For parsing HTTP responses
  @impl true
  def parse({:ok, %{body: body}}) do
    case Jason.decode(body) do
      {:ok, decoded} ->
        opts =
          decoded
          |> Enum.reduce(%{}, fn {k, v}, acc ->
            Map.put(acc, String.to_atom(k), v)
          end)
          |> Map.delete(:created)
          |> Map.put(:created_at, from_unix(decoded))

        struct(__MODULE__, opts)

      {:error, _} ->
        {:error, "Invalid response body"}
    end
  end

  defp from_unix(%{"created" => timestamp}),
    do: DateTime.from_unix!(timestamp)
end
