defmodule OpenAi.Admin.Users.Roles do
  @moduledoc "Organization user role assignments. Needs an admin API key (`OpenAi.Client.new(api_key: admin_key)`)."

  alias OpenAi.Client

  @doc "Lists user role assignments. `GET /organization/users/{user_id}/roles`"
  @spec list(Client.t(), String.t(), map() | keyword(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def list(%Client{} = client, user_id, query \\ [], options \\ []) do
    Client.request(client, :get, path_0(user_id), Keyword.put(options, :query, query))
  end

  @doc "Assigns a role to a user. `POST /organization/users/{user_id}/roles`"
  @spec create(Client.t(), String.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def create(%Client{} = client, user_id, body, options \\ []) when is_map(body) do
    Client.request(client, :post, path_0(user_id), Keyword.put(options, :body, body))
  end

  @doc "Retrieves a user role assignment. `GET /organization/users/{user_id}/roles/{role_id}`"
  @spec retrieve(Client.t(), String.t(), String.t(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def retrieve(%Client{} = client, user_id, role_id, options \\ []) do
    Client.request(client, :get, path_1(user_id, role_id), options)
  end

  @doc "Removes a role from a user. `DELETE /organization/users/{user_id}/roles/{role_id}`"
  @spec delete(Client.t(), String.t(), String.t(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def delete(%Client{} = client, user_id, role_id, options \\ []) do
    Client.request(client, :delete, path_1(user_id, role_id), options)
  end

  defp path_0(user_id), do: "/organization/users/#{Client.path_segment(user_id)}/roles"

  defp path_1(user_id, role_id),
    do: "/organization/users/#{Client.path_segment(user_id)}/roles/#{Client.path_segment(role_id)}"
end
