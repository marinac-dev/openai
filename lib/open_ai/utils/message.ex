defmodule OpenAi.Utils.Message do
  @moduledoc """
  Documentation for `OpenAi.Utils.Message` module.

  This module hold message data for one OpenAI chat completion.
  """

  @enforce_keys [:content, :role]
  defstruct [:content, :role]

  @type t :: %__MODULE__{
          content: String.t(),
          role: String.t()
        }

  defimpl Jason.Encoder, for: __MODULE__ do
    def encode(value, opts) do
      Jason.Encode.map(Map.take(value, [:content, :role]), opts)
    end
  end
end
