defmodule OpenAi do
  @moduledoc """
  Documentation for `OpenAi`.
  See https://platform.openai.com/docs/api-reference for more information.
  """

  use Application

  def start(_type, _args) do
    children = [
      {Finch, name: OpenAiFinch}
    ]

    opts = [strategy: :one_for_one, name: OpenAi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @doc """
  Creates a completion for the chat message

  ### Parameters
  - `prompt` - The prompt for the chat message
  - `options` - A list of options to pass to the API client

      {
        "model": "gpt-3.5-turbo",
        "messages": [{"role": "user", "content": "Hello!"}]
        "max_tokens": 500,
        "temperature": 0.9,
      }

  ### Response

      {
        "id": "chatcmpl-123",
        "object": "chat.completion",
        "created": 1677652288,
        "choices": [{
          "index": 0,
          "message": {
            "role": "assistant",
            "content": "\n\nHello there, how may I assist you today?",
          },
          "finish_reason": "stop"
        }],
        "usage": {
          "prompt_tokens": 9,
          "completion_tokens": 12,
          "total_tokens": 21
        }
      }

  """

  def chat_completion(prompt, options \\ []) do
    OpenAi.Competition.chat_completion(prompt, options)
  end
end
