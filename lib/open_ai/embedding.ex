defmodule OpenAi.Embedding do
  @moduledoc """
  A client for interacting with the OpenAI Embedding API.
  """

  use OpenAi.Core.Client

  @doc false
  scope "/v1/embeddings"

  @doc """
  Creates an embedding vector representing the input text.

  ## Parameters

  - `model`: (String, required) ID of the model to use. Use the List models API to see all available models or see the Model overview for descriptions of them.

  - `input`: (String, required) The text to encode.

  - `user`: (String, optional) A unique identifier representing your end-user, which can help OpenAI to monitor and detect abuse.

  ### Example

      iex> prompt = %{model: "text-embedding-ada-002", input: "Hello, my name is"}
      iex> OpenAi.Embedding.create_embedding(prompt)

  ```elixir
  %Finch.Response{
  status: 200,
  body: "{\n  \"object\": \"list\",\n  \"data\": [\n    {\n      \"object\": \"embedding\",\n      \"index\": 0,\n      \"embedding\": [\n        -0.021661555,\n        -0.0149241,\n        -0.018292828,\n        -0.029009195,\n        -0.025042996,\n        0.050823297,\n        -0.018712329,\n        -0.01597921,\n        -0.0014579282,\n        -0.013010916,\n        0.01953862,\n        0.0051102964,\n        -0.006559485,\n        -0.013856277,\n        -0.009845584,\n        -0.018369101,\n        0.021890374,\n        0.008815897,\n        0.009801091," <> ...,
  headers: [
    {"date", "Mon, 03 Apr 2023 17:51:48 GMT"},
    {"content-type", "application/json"},
    {"content-length", "33439"},
    {"connection", "keep-alive"},
    {"access-control-allow-origin", "*"},
    {"openai-organization", "user-jv3xlepkfrbj6rj6ukbbn7bq"},
    {"openai-processing-ms", "325"},
    {"openai-version", "2020-10-01"},
    {"strict-transport-security", "max-age=15724800; includeSubDomains"},
    {"x-ratelimit-limit-requests", "3000"},
    {"x-ratelimit-remaining-requests", "2999"},
    {"x-ratelimit-reset-requests", "20ms"},
    {"x-request-id", "54f71581db15cda6f0a4f1cde6a456f2"},
    {"cf-cache-status", "DYNAMIC"},
    {"server", "cloudflare"},
    {"cf-ray", "7b232963db26c2f7-VIE"},
    {"alt-svc", "h3=\":443\"; ma=86400, h3-29=\":443\"; ma=86400"}
  ]
  }}
  ```
  """

  @spec create_embedding(map(), keyword() | list()) :: {:ok, map()} | {:error, map()}
  def create_embedding(prompt, options \\ []) do
    jdata = Jason.encode!(prompt)
    post("", jdata, options)
  end
end
