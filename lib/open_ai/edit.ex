defmodule OpenAi.Edit do
  @moduledoc """
  Given a prompt and an instruction, the model will return an edited version of the prompt.
  """

  use OpenAi.Core.Client

  @doc false
  scope "/v1/edits"

  @type edit_body :: %{
    required(:model) => String.t(),
    required(:instruction) => String.t(),
    optional(:input) => String.t(),
    optional(:n) => non_neg_integer(),
    optional(:temperature) => float(),
    optional(:top_p) => float()
  }

  @doc """
  Creates a new edit for the provided input, instruction, and parameters.

  ## Parameters

  - `model` **required** ID of the model to use. You can use the text-davinci-edit-001 or code-davinci-edit-001 model with this endpoint.
  - `instruction` **required** The instruction that tells the model how to edit the prompt.
  - `input` The input text to use as a starting point for the edit.
  - `n` How many edits to generate for the input and instruction. The default is 1.
  - `temperature` What sampling temperature to use, between 0 and 2. Higher values like 0.8 will make the output more random, while lower values like 0.2 will make it more focused and deterministic.
  - `top_p` An alternative to sampling with temperature, called nucleus sampling, where the model considers the results of the tokens with top_p probability mass. So 0.1 means only the tokens comprising the top 10% probability mass are considered.

  ### Example body
  ```elixir
  %{
    model: "text-davinci-edit-001",
    input: "What day of the wek is it?",
    instruction: "Fix the spelling mistakes"
  }
  ```
  """
  @spec create_edit(edit_body(), keyword()) :: {:ok, map()} | {:error, map()}
  def create_edit(body, params \\ []) do
    jdata = Jason.encode!(body)

    post("", jdata, %{}, params)
  end
end
