defmodule OpenAi.Admin.Groups do
  @moduledoc "Organization groups. Needs an admin API key (`OpenAi.Client.new(api_key: admin_key)`)."

  alias OpenAi.Client

  @doc "Lists groups. `GET /organization/groups`"
  @spec list(Client.t(), map() | keyword(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def list(%Client{} = client, query \\ [], options \\ []) do
    Client.request(client, :get, "/organization/groups", Keyword.put(options, :query, query))
  end

  @doc "Creates a group. `POST /organization/groups`"
  @spec create(Client.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def create(%Client{} = client, body, options \\ []) when is_map(body) do
    Client.request(client, :post, "/organization/groups", Keyword.put(options, :body, body))
  end

  @doc "Retrieves a group. `GET /organization/groups/{group_id}`"
  @spec retrieve(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def retrieve(%Client{} = client, group_id, options \\ []) do
    Client.request(client, :get, path(group_id), options)
  end

  @doc "Updates a group. `POST /organization/groups/{group_id}`"
  @spec update(Client.t(), String.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def update(%Client{} = client, group_id, body, options \\ []) when is_map(body) do
    Client.request(client, :post, path(group_id), Keyword.put(options, :body, body))
  end

  @doc "Deletes a group. `DELETE /organization/groups/{group_id}`"
  @spec delete(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def delete(%Client{} = client, group_id, options \\ []) do
    Client.request(client, :delete, path(group_id), options)
  end

  defp path(group_id), do: "/organization/groups/#{Client.path_segment(group_id)}"
end
