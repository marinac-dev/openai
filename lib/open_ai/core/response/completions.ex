defmodule OpenAi.Core.Response.Completions do
  @moduledoc """
  Represents a response from the OpenAI Completions API.
  """

  @behaviour OpenAi.Core.Response

  alias OpenAi.Core.Types.CompletionChoice

  @enforce_keys [:id, :choices, :created, :model, :system_fingerprint, :object, :usage]

  defstruct [:id, :object, :created, :model, :system_fingerprint, :choices, :usage]

  @type t :: %__MODULE__{
          id: String.t(),
          object: String.t(),
          created: Integer.t(),
          model: String.t(),
          system_fingerprint: String.t(),
          choices: [CompletionChoice.t()],
          usage: Usage.t()
        }

  @impl true
  def parse({:ok, %Finch.Response{status: 200, body: body}}) do
    case Jason.decode(body) do
      {:ok, decoded} ->
        struct(__MODULE__, decoded)

      {:error, _} = error ->
        error
    end
  end

  @impl true
  def parse({:error, _} = error), do: error
end
