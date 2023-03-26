defmodule OpenAi.Competition do
  @moduledoc """
  A client for interacting with the OpenAI Competition API.

  ### Chat Parameters
  - `model` - ID of the model to use. You can use the `list_models` API to see all of your available models.
  - `messages` - The messages to generate chat completions for, in the chat format.
  - `temperature` - What sampling temperature to use, between 0 and 2. Higher values like 0.8 will make the output more random, while lower values like 0.2 will make it more focused and deterministic.
  - `top_p` - An alternative to sampling with temperature, called nucleus sampling, where the model considers the results of the tokens with top_p probability mass. So 0.1 means only the tokens comprising the top 10% probability mass are considered.
  - `n` - The number of chat completions to generate. If `n` is greater than 1, the API will return a list of completions.
  - `stream` - If set, partial message deltas will be sent, like in ChatGPT. Tokens will be sent as data-only server-sent events as they become available, with the stream terminated by a data: [DONE] message.
  - `stop` - Up to 4 sequences where the API will stop generating further tokens.
  - `max_tokens` - The maximum number of tokens to generate in the chat completion.
  - `presence_penalty` - Number between -2.0 and 2.0. Positive values penalize new tokens based on whether they appear in the text so far, increasing the model's likelihood to talk about new topics.
  - `frequency_penalty` - Number between -2.0 and 2.0. Positive values penalize new tokens based on their existing frequency in the text so far, decreasing the model's likelihood to repeat the same line verbatim.
  - `logit_bias` - Modify the likelihood of specified tokens appearing in the completion.

        {
          "model": "gpt-3.5-turbo",
          "messages": [{"role": "user", "content": "Hello!"}]
        }

  ### Chat Response

      {
        "id": "chatcmpl-123",
        "object": "chat.completion",
        "created": 1677652288,
        "choices": [{
          "index": 0,
          "message": {
            "role": "assistant",
            "content": "Hello there, how may I assist you today?",
          },
          "finish_reason": "stop"
        }],
        "usage": {
          "prompt_tokens": 9,
          "completion_tokens": 12,
          "total_tokens": 21
        }
      }

  ### Text Parameters

  """

  use OpenAi.Core.Client

  scope "/completions"

  @type chat_params :: %{
          model: String.t(),
          messages: list(),
          temperature: float(),
          top_p: float(),
          n: integer(),
          stream: boolean(),
          stop: list(),
          max_tokens: integer(),
          presence_penalty: float(),
          frequency_penalty: float(),
          logit_bias: map()
        }

  @text_url "/v1/completions"
  @chat_url "/v1/chat/completions"
  @doc """
  Creates a completion for the chat message.

  If the `stream` option is set to `false` (default), the API will return a list of completions in the `choices` field as HTTP response body.

  If the `stream` option is set to `true`, the API will return a stream of partial message deltas, like in ChatGPT.
  Tokens will be sent as data-only server-sent events as they become available, with the stream terminated by a data: [DONE] message.

  ### Example

      iex> {:ok, %{body: stream_ref}} = OpenAi.chat_completion(%{stream: true, model: "gpt-4", messages: [%{role: "user", content: content}]})
      iex> {:ok, %{body: response}} = ref |> Stream.each( * DO SOMETHING WITH THE RESPONSE * ) |> Stream.run()

  ### Parameters
  - `prompt` - The prompt to generate completions for, in the chat format `chat_params`.
  - `options` - A list of options to pass to the API.

  """

  def chat_completion(prompt, options \\ [])

  def chat_completion(%{stream: true} = prompt, options) do
    post(@chat_url, prompt, options)
  end

  def chat_completion(prompt, options) do
    post(@chat_url, prompt, options)
  end

  @doc """
  Creates a completion for the text input.
  """

  def text_completion(prompt, options \\ []) do
    post(@text_url, prompt, options)
  end
end
