defmodule OpenAi.Core.Types.Completion do
  @moduledoc """
  Type definition for Completion struct.
  """

  # * Subtypes
  defmodule CompletionChoice do
    @moduledoc """
    Type definition for Completion Choice struct.
    """

    defstruct [
      :finish_reason,
      :index,
      :logprobs,
      :text
    ]

    @type t :: %__MODULE__{
            finish_reason: String.t(),
            index: Integer.t(),
            logprobs: Logprobs.t(),
            text: String.t()
          }
  end

  defmodule Logprobs do
    @moduledoc """
    Type definition for Logprobs struct.
    """

    defstruct [
      :tokens,
      :textoffset,
      :token_logprobs,
      :top_logprobs
    ]

    @type t :: %__MODULE__{
            tokens: [String.t()],
            textoffset: [Integer.t()],
            token_logprobs: [Float.t()],
            top_logprobs: [Float.t()]
          }
  end

  # * Struct

  @enforce_keys [:id, :choices, :created, :model, :object, :system_fingerprint, :usage]

  defstruct [
    :id,
    :choices,
    :created,
    :model,
    :object,
    :system_fingerprint,
    :usage
  ]

  @type t :: %__MODULE__{
          id: String.t(),
          choices: [CompletionChoice.t()],
          created: String.t(),
          model: String.t(),
          object: String.t(),
          system_fingerprint: String.t(),
          usage: String.t()
        }
end
