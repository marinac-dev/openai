defmodule OpenAi.ChatCompletion do
  @moduledoc """
  A client for interacting with the OpenAI chat completion API.

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

  ### Chat Message Format (JSON)

  ```json
  {
    "model": "gpt-3.5-turbo",
    "messages": [{"role": "user", "content": "Hello!"}]
  }
  ```

  ### Chat Response

  ```json
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
  ```
  """

  use OpenAi.Core.Client

  @doc false
  scope "/v1/chat/completions"

  @type message_object :: %{
          role: String.t(),
          content: String.t(),
          name: String.t(),
          function_call: map()
        }

  @type function_object :: %{
          name: String.t(),
          description: String.t(),
          parameters: String.t()
        }

  @type chat_params :: %{
          model: String.t(),
          messages: [message_object()],
          functions: function_object(),
          function_call: String.t() | map(),
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

  @doc """
  Creates a completion for the chat message.

  If the `stream` option is set to `false` (default), the API will return a list of completions in the `choices` field as HTTP response body.

  If the `stream` option is set to `true`, the API will return a stream of partial message deltas, like in ChatGPT.
  Tokens will be sent as data-only server-sent events as they become available, with the stream terminated by a data: [DONE] message.

  ### Parameters
  - `prompt` - The prompt to generate completions for, in the chat format `chat_params`.
  - `options` - A list of options to pass to the API.

  ### Example

      iex> prompt = %{model: "gpt-3.5-turbo", messages: [%{role: "user", content: "Hello!"}], stream: true}
      iex> OpenAi.ChatCompetition.chat_completion(prompt)
      # Input is manually truncated for brevity
      %{
        body: [
          "data": [DONE]",
          "data: {\"id\":\"chatcmpl-71J1h5BzDi9VhHuScOuNGrlxmexoU\",\"object\":\"chat.completion.chunk\",\"created\":1680545821,\"model\":\"gpt-3.5-turbo-0301\",\"choices\":[{\"delta\":{},\"index\":0,\"finish_reason\":\"stop\"}]}",
          "data: {\"id\":\"chatcmpl-71J1h5BzDi9VhHuScOuNGrlxmexoU\",\"object\":\"chat.completion.chunk\",\"created\":1680545821,\"model\":\"gpt-3.5-turbo-0301\",\"choices\":[{\"delta\":{\"content\":\"?\"},\"index\":0,\"finish_reason\":null}]}",
          "data: {\"id\":\"chatcmpl-71J1h5BzDi9VhHuScOuNGrlxmexoU\",\"object\":\"chat.completion.chunk\",\"created\":1680545821,\"model\":\"gpt-3.5-turbo-0301\",\"choices\":[{\"delta\":{\"content\":\" today\"},\"index\":0,\"finish_reason\":null}]},
          <> ...
        ],
        headers: [
          {"date", "Mon, 03 Apr 2023 18:17:01 GMT"},
          {"content-type", "text/event-stream"},
          {"transfer-encoding", "chunked"},
          {"connection", "keep-alive"},
          {"access-control-allow-origin", "*"},
          {"cache-control", "no-cache, must-revalidate"},
          {"openai-model", "gpt-3.5-turbo-0301"},
          {"openai-processing-ms", "139"},
          {"openai-version", "2020-10-01"},
          {"strict-transport-security", "max-age=15724800; includeSubDomains"},
          {"x-ratelimit-limit-requests", "3500"},
          {"x-ratelimit-remaining-requests", "3499"},
          {"x-ratelimit-reset-requests", "17ms"},
          {"cf-cache-status", "DYNAMIC"},
        ],
        status: 200,
        type: :stream
      }
  """

  @spec chat_completion(chat_params(), keyword(), function()) :: {:ok, Finch.Response.t()} | {:error, Exception.t()}

  def chat_completion(%{stream: true} = prompt, options, :default),
    do: chat_completion(prompt, options, &default_stream_callback/2)

  def chat_completion(%{stream: true} = prompt, options, stream_callback) do
    jdata = Jason.encode!(prompt)
    conn = %{headers: nil, status: nil, body: [], type: :stream}
    stream(:post, "", jdata, options, conn, stream_callback)
  end

  def chat_completion(prompt, options, _) do
    jdata = Jason.encode!(prompt)
    post("", jdata, %{}, options)
  end

  defp default_stream_callback({:status, data}, acc), do: %{acc | status: data}
  defp default_stream_callback({:headers, headers}, acc), do: %{acc | headers: headers}
  defp default_stream_callback({:data, data}, %{body: body} = acc), do: %{acc | body: [data | body]}
end
