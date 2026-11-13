defmodule OpenAi.Admin.Groups.Roles do
  @moduledoc "Organization group role assignments. Needs an admin API key (`OpenAi.Client.new(api_key: admin_key)`)."

  alias OpenAi.Client

  @doc "Lists group role assignments. `GET /organization/groups/{group_id}/roles`"
  @spec list(Client.t(), String.t(), map() | keyword(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def list(%Client{} = client, group_id, query \\ [], options \\ []) do
    Client.request(client, :get, path_0(group_id), Keyword.put(options, :query, query))
  end

  @doc "Assigns a role to a group. `POST /organization/groups/{group_id}/roles`"
  @spec create(Client.t(), String.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def create(%Client{} = client, group_id, body, options \\ []) when is_map(body) do
    Client.request(client, :post, path_0(group_id), Keyword.put(options, :body, body))
  end

  @doc "Retrieves a group role assignment. `GET /organization/groups/{group_id}/roles/{role_id}`"
  @spec retrieve(Client.t(), String.t(), String.t(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def retrieve(%Client{} = client, group_id, role_id, options \\ []) do
    Client.request(client, :get, path_1(group_id, role_id), options)
  end

  @doc "Removes a role from a group. `DELETE /organization/groups/{group_id}/roles/{role_id}`"
  @spec delete(Client.t(), String.t(), String.t(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def delete(%Client{} = client, group_id, role_id, options \\ []) do
    Client.request(client, :delete, path_1(group_id, role_id), options)
  end

  defp path_0(group_id), do: "/organization/groups/#{Client.path_segment(group_id)}/roles"

  defp path_1(group_id, role_id),
    do: "/organization/groups/#{Client.path_segment(group_id)}/roles/#{Client.path_segment(role_id)}"
end
