defmodule OpenAi.Core.Response.ListModels do
  @moduledoc """
  Structure for parsing OpenAI API responses for `list_models`
  """
  @behaviour OpenAi.Core.Response

  @enforce_keys [:object, :data]
  defstruct [:object, :data]

  @type t :: %__MODULE__{
          object: String.t(),
          data: list(map())
        }

  @impl true
  def parse({:ok, %{body: body}}) do
    case Jason.decode(body) do
      {:ok, %{"object" => object, "data" => data}} ->
        %__MODULE__{
          object: object,
          data: data
        }

      {:error, _} ->
        {:error, %{"message" => "Unable to parse response"}}
    end
  end
end
