defmodule OpenAi.Assistants do
  @moduledoc """
  Assistants. Deprecated by OpenAI in favour of the Responses API.
  """

  alias OpenAi.Client

  @doc "Lists assistants. `GET /assistants`"
  @spec list(Client.t(), map() | keyword(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def list(%Client{} = client, query \\ [], options \\ []) do
    Client.request(client, :get, "/assistants", Keyword.put(options, :query, query))
  end

  @doc "Creates an assistant. `POST /assistants`"
  @spec create(Client.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def create(%Client{} = client, body, options \\ []) when is_map(body) do
    Client.request(client, :post, "/assistants", Keyword.put(options, :body, body))
  end

  @doc "Retrieves an assistant. `GET /assistants/{assistant_id}`"
  @spec retrieve(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def retrieve(%Client{} = client, assistant_id, options \\ []) do
    Client.request(client, :get, path(assistant_id), options)
  end

  @doc "Modifies an assistant. `POST /assistants/{assistant_id}`"
  @spec update(Client.t(), String.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def update(%Client{} = client, assistant_id, body, options \\ []) when is_map(body) do
    Client.request(client, :post, path(assistant_id), Keyword.put(options, :body, body))
  end

  @doc "Deletes an assistant. `DELETE /assistants/{assistant_id}`"
  @spec delete(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def delete(%Client{} = client, assistant_id, options \\ []) do
    Client.request(client, :delete, path(assistant_id), options)
  end

  defp path(assistant_id), do: "/assistants/" <> Client.path_segment(assistant_id)
end
