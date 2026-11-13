defmodule OpenAi.Admin.AdminApiKeys do
  @moduledoc "Organization admin API keys. Needs an admin API key (`OpenAi.Client.new(api_key: admin_key)`)."

  alias OpenAi.Client

  @doc "Lists admin API keys. `GET /organization/admin_api_keys`"
  @spec list(Client.t(), map() | keyword(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def list(%Client{} = client, query \\ [], options \\ []) do
    Client.request(client, :get, "/organization/admin_api_keys", Keyword.put(options, :query, query))
  end

  @doc "Creates an admin API key. `POST /organization/admin_api_keys`"
  @spec create(Client.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def create(%Client{} = client, body, options \\ []) when is_map(body) do
    Client.request(client, :post, "/organization/admin_api_keys", Keyword.put(options, :body, body))
  end

  @doc "Retrieves an admin API key. `GET /organization/admin_api_keys/{key_id}`"
  @spec retrieve(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def retrieve(%Client{} = client, key_id, options \\ []) do
    Client.request(client, :get, path(key_id), options)
  end

  @doc "Deletes an admin API key. `DELETE /organization/admin_api_keys/{key_id}`"
  @spec delete(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def delete(%Client{} = client, key_id, options \\ []) do
    Client.request(client, :delete, path(key_id), options)
  end

  defp path(key_id), do: "/organization/admin_api_keys/#{Client.path_segment(key_id)}"
end
