defmodule OpenAi.Moderation do
  @moduledoc """
  Given a input text, outputs if the model classifies it as violating OpenAI's content policy.

  [Read more](https://platform.openai.com/docs/guides/moderation)
  """

  use OpenAi.Core.Client

  @doc false
  scope "/v1/moderations"

  @doc """
  Classifies if text violates OpenAI's Content Policy

  ## Parameters

  - `input` The input text to classify
  - `model` ID of the model to use. Two content moderations models are available: text-moderation-stable and text-moderation-latest. The default is text-moderation-latest which will be automatically upgraded over time. This ensures you are always using our most accurate model. If you use text-moderation-stable, we will provide advanced notice before updating the model. Accuracy of text-moderation-stable may be slightly lower than for text-moderation-latest.
  """
  @spec classify(String.t(), String.t(), keyword()) :: {:ok, map()} | {:error, map()}
  def classify(input, model, params \\ []) do
    body = %{
      input: input,
      model: model
    }

    jdata = Jason.encode!(body)

    post("", jdata, %{}, params)
  end
end
