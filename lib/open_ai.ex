defmodule OpenAi do
  @moduledoc """
  Elixir client for the [OpenAI API](https://platform.openai.com/docs/api-reference).

  The functions in this module are conveniences that build a client from application config
  (see `client/1`) and delegate to the resource modules, such as `OpenAi.Responses`,
  `OpenAi.Chat.Completions`, and `OpenAi.Models`. Every function returns `{:ok, result}` or
  `{:error, %OpenAi.Error{}}`. For streaming, use `OpenAi.Responses.stream/4` or
  `OpenAi.Chat.Completions.stream/4` with an explicit client.
  """

  use Application

  alias OpenAi.{Chat, Client, Completions, Embeddings, Files, Models, Moderations}

  @doc false
  def start(_type, _args) do
    children = [
      {Finch, name: OpenAiFinch}
    ]

    opts = [strategy: :one_for_one, name: OpenAi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @doc "Creates an explicit OpenAI API client."
  @spec client(keyword()) :: Client.t()
  def client(options \\ []), do: Client.new(options)

  @doc "Calls any OpenAI REST endpoint using a client built from application config."
  @spec request(atom(), String.t(), Client.request_options()) ::
          {:ok, term()} | {:error, OpenAi.Error.t()}
  def request(method, path, options \\ []), do: Client.request(client(), method, path, options)

  @doc "Lists the models available to your account."
  @spec list_models() :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def list_models, do: Models.list(client())

  @doc """
  Retrieves a model.

      OpenAi.retrieve_model("gpt-5.4")
  """
  @spec retrieve_model(String.t()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def retrieve_model(model_id), do: Models.retrieve(client(), model_id)

  @doc """
  Creates a chat completion.

      OpenAi.chat_completion(%{model: "gpt-5.4", messages: [%{role: "user", content: "Hello!"}]})
  """
  @spec chat_completion(map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def chat_completion(body, options \\ []), do: Chat.Completions.create(client(), body, options)

  @doc """
  Creates a legacy text completion.

      OpenAi.text_completion(%{model: "gpt-3.5-turbo-instruct", prompt: "Say hello", max_tokens: 16})
  """
  @spec text_completion(map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def text_completion(body, options \\ []), do: Completions.create(client(), body, options)

  @doc """
  Creates an embedding vector representing the input text.

      OpenAi.embed_text(%{model: "text-embedding-3-small", input: "The food was delicious"})
  """
  @spec embed_text(map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def embed_text(body, options \\ []), do: Embeddings.create(client(), body, options)

  @doc """
  Classifies whether the input violates OpenAI's content policy.

      OpenAi.moderation("some text to check")
  """
  @spec moderation(String.t() | list(), String.t(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def moderation(input, model \\ "omni-moderation-latest", options \\ []) do
    Moderations.create(client(), %{input: input, model: model}, options)
  end

  @doc "Lists the files that belong to your organization."
  @spec list_files() :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def list_files, do: Files.list(client())

  @doc """
  Uploads the file at `file_path` for the given `purpose` (for example `"user_data"` or `"batch"`).
  """
  @spec upload_file(String.t(), String.t(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def upload_file(file_path, purpose, options \\ []) do
    Files.create(client(), %{file: file_path, purpose: purpose}, options)
  end

  @doc "Deletes a file."
  @spec delete_file(String.t()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def delete_file(file_id), do: Files.delete(client(), file_id)

  @doc "Returns information about a specific file."
  @spec retrieve_file(String.t()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def retrieve_file(file_id), do: Files.retrieve(client(), file_id)

  @doc "Returns the raw contents of a file."
  @spec file_content(String.t()) :: {:ok, binary()} | {:error, OpenAi.Error.t()}
  def file_content(file_id), do: Files.content(client(), file_id)
end
