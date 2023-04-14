defmodule OpenAi.TextCompletion do
  use OpenAi.Core.Client

  @doc false
  scope "/v1/completions"

  @type text_params :: %{
          model: String.t(),
          prompt: String.t(),
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
  Generates text completions based on the given parameters.

  ## Parameters

  - `model`: (String, required) ID of the model to use. Use the List models API to see all available models or see the Model overview for descriptions of them.
  - `prompt`: (String or Array, optional, defaults to "") The prompt(s) to generate completions for, encoded as a string, array of strings, array of tokens, or array of token arrays.
  - `suffix`: (String, optional, defaults to null) The suffix that comes after a completion of inserted text.
  - `max_tokens`: (Integer, optional, defaults to 16) The maximum number of tokens to generate in the completion.
  - `temperature`: (Number, optional, defaults to 1) Sampling temperature to use, between 0 and 2. Higher values make the output more random, lower values make it more focused and deterministic.
  - `top_p`: (Number, optional, defaults to 1) Nucleus sampling parameter. The model considers the results of the tokens with top_p probability mass. 0.1 means only the tokens comprising the top 10% probability mass are considered.
  - `n`: (Integer, optional, defaults to 1) How many completions to generate for each prompt.
  - `stream`: (Boolean, optional, defaults to false) Whether to stream back partial progress. Tokens will be sent as data-only server-sent events as they become available, with the stream terminated by a data: [DONE] message.
  - `logprobs`: (Integer, optional, defaults to null) Include the log probabilities on the logprobs most likely tokens, as well the chosen tokens.
  - `echo`: (Boolean, optional, defaults to false) Echo back the prompt in addition to the completion.
  - `stop`: (String or Array, optional, defaults to null) Up to 4 sequences where the API will stop generating further tokens. The returned text will not contain the stop sequence.
  - `presence_penalty`: (Number, optional, defaults to 0) Number between -2.0 and 2.0. Positive values penalize new tokens based on whether they appear in the text so far, increasing the model's likelihood to talk about new topics.
  - `frequency_penalty`: (Number, optional, defaults to 0) Number between -2.0 and 2.0. Positive values penalize new tokens based on their existing frequency in the text so far, decreasing the model's likelihood to repeat the same line verbatim.
  - `best_of`: (Integer, optional, defaults to 1) Generates best_of completions server-side and returns the "best" (the one with the highest log probability per token). Results cannot be streamed.
  - `logit_bias`: (Map, optional, defaults to null) Modify the likelihood of specified tokens appearing in the completion.
  - `user`: (String, optional) A unique identifier representing your end-user, which can help OpenAI to monitor and detect abuse.

  ## Examples

      iex> prompt = %{model: "text-davinci-003", prompt: "Hello, my name is", max_tokens: 500}
      iex> text_completion(prompt)
  """

  @spec text_completion(text_params(), keyword()) :: {:ok, %Finch.Response{}} | {:error, map()}
  def text_completion(prompt, options \\ [])

  def text_completion(%{stream: true} = prompt, options) do
    jdata = Jason.encode!(prompt)
    conn = %{headers: nil, status: nil, body: [], type: :stream}
    stream(:post, "", jdata, options, conn, &stream_callback/2)
  end

  def text_completion(prompt, options) do
    jdata = Jason.encode!(prompt)
    post("", jdata, options)
  end

  defp stream_callback({:status, data}, acc), do: %{acc | status: data}
  defp stream_callback({:headers, headers}, acc), do: %{acc | headers: headers}
  defp stream_callback({:data, data}, %{body: body} = acc), do: %{acc | body: [data | body]}
end
