defmodule OpenAi.Admin.Roles do
  @moduledoc "Organization roles. Needs an admin API key (`OpenAi.Client.new(api_key: admin_key)`)."

  alias OpenAi.Client

  @doc "Lists organization roles. `GET /organization/roles`"
  @spec list(Client.t(), map() | keyword(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def list(%Client{} = client, query \\ [], options \\ []) do
    Client.request(client, :get, "/organization/roles", Keyword.put(options, :query, query))
  end

  @doc "Creates an organization role. `POST /organization/roles`"
  @spec create(Client.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def create(%Client{} = client, body, options \\ []) when is_map(body) do
    Client.request(client, :post, "/organization/roles", Keyword.put(options, :body, body))
  end

  @doc "Retrieves an organization role. `GET /organization/roles/{role_id}`"
  @spec retrieve(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def retrieve(%Client{} = client, role_id, options \\ []) do
    Client.request(client, :get, path(role_id), options)
  end

  @doc "Updates an organization role. `POST /organization/roles/{role_id}`"
  @spec update(Client.t(), String.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def update(%Client{} = client, role_id, body, options \\ []) when is_map(body) do
    Client.request(client, :post, path(role_id), Keyword.put(options, :body, body))
  end

  @doc "Deletes an organization role. `DELETE /organization/roles/{role_id}`"
  @spec delete(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def delete(%Client{} = client, role_id, options \\ []) do
    Client.request(client, :delete, path(role_id), options)
  end

  defp path(role_id), do: "/organization/roles/#{Client.path_segment(role_id)}"
end
