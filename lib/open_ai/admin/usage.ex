defmodule OpenAi.Admin.Usage do
  @moduledoc "Organization usage. Needs an admin API key (`OpenAi.Client.new(api_key: admin_key)`)."

  alias OpenAi.Client

  @doc "Retrieves audio speeches usage. `GET /organization/usage/audio_speeches`"
  @spec audio_speeches(Client.t(), map() | keyword(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def audio_speeches(%Client{} = client, query \\ [], options \\ []) do
    Client.request(client, :get, "/organization/usage/audio_speeches", Keyword.put(options, :query, query))
  end

  @doc "Retrieves audio transcriptions usage. `GET /organization/usage/audio_transcriptions`"
  @spec audio_transcriptions(Client.t(), map() | keyword(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def audio_transcriptions(%Client{} = client, query \\ [], options \\ []) do
    Client.request(client, :get, "/organization/usage/audio_transcriptions", Keyword.put(options, :query, query))
  end

  @doc "Retrieves code interpreter sessions usage. `GET /organization/usage/code_interpreter_sessions`"
  @spec code_interpreter_sessions(Client.t(), map() | keyword(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def code_interpreter_sessions(%Client{} = client, query \\ [], options \\ []) do
    Client.request(client, :get, "/organization/usage/code_interpreter_sessions", Keyword.put(options, :query, query))
  end

  @doc "Retrieves completions usage. `GET /organization/usage/completions`"
  @spec completions(Client.t(), map() | keyword(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def completions(%Client{} = client, query \\ [], options \\ []) do
    Client.request(client, :get, "/organization/usage/completions", Keyword.put(options, :query, query))
  end

  @doc "Retrieves embeddings usage. `GET /organization/usage/embeddings`"
  @spec embeddings(Client.t(), map() | keyword(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def embeddings(%Client{} = client, query \\ [], options \\ []) do
    Client.request(client, :get, "/organization/usage/embeddings", Keyword.put(options, :query, query))
  end

  @doc "Retrieves file search calls usage. `GET /organization/usage/file_search_calls`"
  @spec file_search_calls(Client.t(), map() | keyword(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def file_search_calls(%Client{} = client, query \\ [], options \\ []) do
    Client.request(client, :get, "/organization/usage/file_search_calls", Keyword.put(options, :query, query))
  end

  @doc "Retrieves images usage. `GET /organization/usage/images`"
  @spec images(Client.t(), map() | keyword(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def images(%Client{} = client, query \\ [], options \\ []) do
    Client.request(client, :get, "/organization/usage/images", Keyword.put(options, :query, query))
  end

  @doc "Retrieves moderations usage. `GET /organization/usage/moderations`"
  @spec moderations(Client.t(), map() | keyword(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def moderations(%Client{} = client, query \\ [], options \\ []) do
    Client.request(client, :get, "/organization/usage/moderations", Keyword.put(options, :query, query))
  end

  @doc "Retrieves vector stores usage. `GET /organization/usage/vector_stores`"
  @spec vector_stores(Client.t(), map() | keyword(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def vector_stores(%Client{} = client, query \\ [], options \\ []) do
    Client.request(client, :get, "/organization/usage/vector_stores", Keyword.put(options, :query, query))
  end

  @doc "Retrieves web search calls usage. `GET /organization/usage/web_search_calls`"
  @spec web_search_calls(Client.t(), map() | keyword(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def web_search_calls(%Client{} = client, query \\ [], options \\ []) do
    Client.request(client, :get, "/organization/usage/web_search_calls", Keyword.put(options, :query, query))
  end
end
