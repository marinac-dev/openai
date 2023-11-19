defmodule OpenAi.Core.Response.Embeddings do
  @moduledoc """
  Documentation for `Embeddings` response.
  """

  @behaviour OpenAi.Core.Response

  @enforce_keys [:object, :embedding, :index]
  defstruct [:object, :embedding, :index]

  @type t :: %__MODULE__{
          object: String.t(),
          embedding: list(number()),
          index: number()
        }

  # * For parsing HTTP responses
  @impl true
  def parse({:ok, %{body: body}}) do
    case Jason.decode(body, keys: :atoms) do
      {:ok, decoded} ->
        opts =
          decoded
          |> Enum.reduce(%{}, fn {k, v}, acc ->
            Map.put(acc, String.to_atom(k), v)
          end)

        struct(__MODULE__, opts)

      {:error, _} ->
        {:error, "Invalid response body"}
    end
  end
end
