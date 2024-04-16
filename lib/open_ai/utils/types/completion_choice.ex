defmodule OpenAi.Utils.Types.CompletionChoice do
  @moduledoc """
  Type definition for Completion Choice struct.
  """

  defstruct [
    :finish_reason,
    :index,
    :logprobs,
    :message
  ]

  @type t :: %__MODULE__{
          finish_reason: String.t(),
          index: Integer.t(),
          logprobs: Logprobs.t(),
          message: String.t()
        }
end
