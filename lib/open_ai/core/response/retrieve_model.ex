defmodule OpenAi.Core.Response.RetrieveModel do
  @moduledoc """
  Structure for parsing OpenAI API responses for `retrieve_model`
  """
  @behaviour OpenAi.Core.Response

  @enforce_keys [:id, :object, :owned_by, :permission]
  defstruct [:id, :object, :owned_by, :permission]

  @type t :: %__MODULE__{
          id: String.t(),
          object: String.t(),
          owned_by: String.t(),
          permission: list(map())
        }

  @impl true
  def parse({:ok, %{body: body}}) do
    case Jason.decode(body) do
      {:ok, %{"id" => id, "object" => object, "owned_by" => owned_by, "permission" => permission}} ->
        %__MODULE__{
          id: id,
          object: object,
          owned_by: owned_by,
          permission: permission
        }

      {:error, _} ->
        {:error, %{"message" => "Unable to parse response"}}
    end
  end
end
