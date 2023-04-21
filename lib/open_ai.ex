defmodule OpenAi do
  @moduledoc """
  Documentation for `OpenAi`.
  See [OpenAi API docs](https://platform.openai.com/docs/api-reference) for more information.
  """

  use Application
  require Logger
  alias OpenAi.Utils.SseParser

  @doc false
  def start(_type, _args) do
    children = [
      {Finch, name: OpenAiFinch}
    ]

    opts = [strategy: :one_for_one, name: OpenAi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @doc """
  Creates a completion for the chat message

  ### Example

      iex> prompt = %{model: "gpt-3.5-turbo", messages: [%{role: "user", content: "Hello!"}], stream: true}
      iex> chat_completion(prompt)
      {:ok, "Hello! How may I assist you today?"}
  """

  @spec chat_completion(map(), list()) :: {:ok, String.t()} | {:ok, map()} | {:error, map()}
  def chat_completion(prompt, options \\ [])

  def chat_completion(%{stream: true} = prompt, options) do
    OpenAi.ChatCompletion.chat_completion(prompt, options) |> parse_response()
  end

  def chat_completion(prompt, options) do
    OpenAi.ChatCompletion.chat_completion(prompt, options) |> parse_response()
  end

  @doc """
  Creates a completion for the text input

  ### Example

      iex> params = %{model: "text-davinci-003", prompt: "Hello, my name is", max_tokens: 500}
      iex> OpenAi.text_completion(params)
      {:ok,
        %{
          "choices" => [
            %{
              "finish_reason" => "stop",
              "index" => 0,
              "logprobs" => nil,
              "text" => "Hi there! Nice to meet you!"
            }
          ],
          "created" => 1680536541,
          "id" => "cmpl-71GG146yP5Fq3nkLaBtECakV3gfzY",
          "model" => "text-davinci-003",
          "object" => "text_completion",
          "usage" => %{
            "completion_tokens" => 12,
            "prompt_tokens" => 3,
            "total_tokens" => 15
          }
        }
      }
  """

  @spec text_completion(map(), list()) :: {:ok, map()} | {:ok, String.t()} | {:error, map()}
  def text_completion(prompt, options \\ []) do
    OpenAi.TextCompletion.text_completion(prompt, options) |> parse_response()
  end

  @doc """
  Creates an embedding vector representing the input text.

  ### Example
      iex> prompt = %{model: "text-embedding-ada-002", input: "The food was delicious and the waiter..."}
      iex> OpenAi.embed_text(prompt)
      {:ok,
      %{
        "data" => [
          %{
            "embedding" => [-0.021522176, -0.014890195, -0.018460283, -0.029145142,
              -0.02502874, 0.050845187, -0.018511103, -0.015792245, -0.0012966983,
              -0.013047977, 0.019705368, 0.0050216294, -0.0069686617, -0.013975439,
              -0.013467241, 0.016541837, 7.7867415e-5, 0.0030603034, -0.027595138,
              -0.0067907926, ...],
            "index" => 0,
            "object" => "embedding"
          }
        ],
        "model" => "text-embedding-ada-002-v2",
        "object" => "list",
        "usage" => %{"prompt_tokens" => 5, "total_tokens" => 5}
        }
      }

  """
  @spec embed_text(map(), list()) :: {:ok, map()} | {:error, map()}
  def embed_text(prompt, options \\ []) do
    OpenAi.Embedding.create_embedding(prompt, options) |> parse_response()
  end

  @doc """
  Returns a list of files that belong to the user's organization.
  """
  @spec list_files() :: {:ok, map()} | {:error, map()}
  def list_files() do
    OpenAi.Files.list_files() |> parse_response()
  end

  @doc """
  Upload a file that contains document(s) to be used across various endpoints/features.
  Currently, the size of all the files uploaded by one organization can be up to 1 GB
  """
  @spec upload_file(String.t(), String.t(), list()) :: {:ok, map()} | {:error, map()}
  def upload_file(file_path, purpose, options \\ []) do
    OpenAi.Files.upload_file({file_path, purpose}, options) |> parse_response()
  end

  @doc """
  Delete a file
  """
  @spec delete_file(String.t()) :: {:ok, map()} | {:error, map()}
  def delete_file(file_id) do
    OpenAi.Files.delete_file(file_id) |> parse_response()
  end

  @doc """
  Returns information about a specific file.
  """
  @spec retrieve_file(String.t()) :: {:ok, map()} | {:error, map()}
  def retrieve_file(file_id) do
    OpenAi.Files.retrieve_file(file_id) |> parse_response()
  end

  @doc """
  Returns the contents of the specified file.
  Takes a file id and returns the contents of the file.
  """
  @spec file_content(String.t()) :: {:ok, map()} | {:error, map()}
  def file_content(file_id) do
    OpenAi.Files.retrieve_file_content(file_id) |> parse_response()
  end

  # * Private helpers

  defp parse_response({:ok, %{type: :stream, body: stream}}), do: {:ok, SseParser.parse(stream)}
  defp parse_response({:ok, %{body: body}}), do: body |> Jason.decode()

  defp parse_response({:error, %Mint.TransportError{reason: :timeout}} = error) do
    Logger.error("OpenAi request timed out with error: #{inspect(error)}")
    {:error, error}
  end

  defp parse_response({:error, %Finch.Error{} = error}) do
    {:error, error}
  end
end
