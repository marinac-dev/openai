defmodule OpenAi do
  @moduledoc """
  Documentation for `OpenAi`.
  See [OpenAi API docs](https://platform.openai.com/docs/api-reference) for more information.
  """

  use Application
  require Logger

  alias OpenAi.Core.Response.ListModels
  alias OpenAi.Core.Response.RetrieveModel
  alias OpenAi.Core.Response.ChatCompletion

  @doc false
  def start(_type, _args) do
    children = [
      {Finch, name: OpenAiFinch}
    ]

    opts = [strategy: :one_for_one, name: OpenAi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @doc """
  Lists the currently available models, and provides basic information about each one such as the owner and availability.
  """
  @spec list_models() :: {:ok, map()} | {:error, map()}
  def list_models() do
    OpenAi.Models.list_models() |> parse_response()
  end

  @doc """
  Retrieves a model instance, providing basic information about the model such as the owner and permissioning.

  ### Example

      iex> OpenAi.retrieve_model("gpt-4")
      {:ok,
      %{
        "created" => 1678604602,
        "id" => "gpt-4",
        "object" => "model",
        "owned_by" => "openai",
        "parent" => nil,
        "permission" => [
          %{
            "allow_create_engine" => false,
            "allow_fine_tuning" => true,
            "allow_logprobs" => true,
            "allow_sampling" => true,
            "allow_search_indices" => false,
            "allow_view" => false,
            "created" => 1681332181,
            "group" => nil,
            "id" => "modelperm-dIkqFqETCY114q1m9DoYiQgO",
            "is_blocking" => false,
            "object" => "model_permission",
            "organization" => "*"
          }
        ],
        "root" => "gpt-4"
      }}
  """
  @spec retrieve_model(String.t()) :: {:ok, map()} | {:error, map()}
  def retrieve_model(model_id) do
    OpenAi.Models.retrieve_model(model_id) |> parse_response()
  end

  @doc """
  Creates a completion for the chat message

  ### Example

      iex> prompt = %{model: "gpt-3.5-turbo", messages: [%{role: "user", content: "Hello!"}], stream: true}
      iex> chat_completion(prompt)
      {:ok, "Hello! How may I assist you today?"}
  """

  @spec chat_completion(map(), list()) :: {:ok, String.t()} | {:ok, map()} | {:error, map()}
  def chat_completion(prompt, streaming_callback \\ :default, options \\ []) do
    OpenAi.ChatCompletion.chat_completion(prompt, streaming_callback, options) |> ChatCompletion.parse()
  end

  @doc """
  Creates a completion for the text input

  ### Example

      iex> prompt = %{model: "text-davinci-003", prompt: "Hello, my name is", max_tokens: 500}
      iex> OpenAi.text_completion(prompt)
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

  @spec text_completion(map(), function(), list()) :: {:ok, map() | String.t()} | {:error, map()}
  def text_completion(prompt, streaming_callback \\ :default, options \\ []) do
    OpenAi.TextCompletion.text_completion(prompt, options, streaming_callback) |> parse_response()
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
  Given a prompt and an instruction, the model will return an edited version of the prompt.

  Example:

      iex> prompt = %{
            model: "text-davinci-edit-001",
            input: "What day of the wek is it?",
            instruction: "Fix the spelling mistakes"
          }
      iex> OpenAi.edit_text(prompt)
      {:ok,
        %{
          "choices" => [%{"index" => 0, "text" => "What day of the week is it?\\n"}],
          "created" => 1_685_647_714,
          "object" => "edit",
          "usage" => %{
            "completion_tokens" => 28,
            "prompt_tokens" => 25,
            "total_tokens" => 53
          }
        }}
  """
  @spec edit_text(map(), list()) :: {:ok, map()} | {:error, map()}
  def edit_text(prompt, options \\ []) do
    OpenAi.Edit.create_edit(prompt, options) |> parse_response()
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

  @doc """
  Given a input text, outputs if the model classifies it as violating OpenAI's content policy.

  Example:

      iex(1)> OpenAi.moderation "API TEST: I want to [REDACTED] myself"
      {:ok,
      %{
        "id" => "modr-[REDACTED]",
        "model" => "text-moderation-004",
        "results" => [
          %{
            "categories" => %{
              "hate" => false,
              "hate/threatening" => false,
              "self-harm" => true,
              "sexual" => false,
              "sexual/minors" => false,
              "violence" => false,
              "violence/graphic" => false
            },
            "category_scores" => %{
              "hate" => 8.627928e-5,
              "hate/threatening" => 2.786682e-6,
              "self-harm" => 0.9999901,
              "sexual" => 1.0644417e-5,
              "sexual/minors" => 3.3277047e-7,
              "violence" => 0.029253,
              "violence/graphic" => 4.117339e-5
            },
            "flagged" => true
          }
        ]
      }}
  """
  @spec moderation(String.t(), String.t(), list()) :: {:ok, map()} | {:error, map()}
  def moderation(text, model \\ "text-moderation-latest", options \\ []) do
    OpenAi.Moderation.classify(text, model, options) |> parse_response()
  end

  # * Private helpers
  defp parse_response({:ok, %{body: body, status: status_code}}) when status_code >= 400 and status_code < 500 do
    {:error, %{status_code: status_code, body: body}}
  end

  defp parse_response({:ok, %{body: stream, type: :stream}}),
    do: {:ok, SseParser.parse(stream)}

  defp parse_response({:ok, %{body: body}}),
    do: body |> Jason.decode()

  defp parse_response({:error, %Mint.TransportError{reason: :timeout} = error}) do
    Logger.error("OpenAi request timed out with error: #{inspect(error)}")
    {:error, error}
  end

  defp parse_response({:error, %Finch.Error{} = error}), do: {:error, error}

  defp parse_response({:error, error}) do
    Logger.error("OpenAi request failed with error: #{inspect(error)}")
    {:error, error}
  end
end
