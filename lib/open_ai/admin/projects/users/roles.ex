defmodule OpenAi.Admin.Projects.Users.Roles do
  @moduledoc "Project admin API: Users.Roles. Requires an admin API key."

  alias OpenAi.Client

  @doc "Lists user role assignments. `GET /projects/{project_id}/users/{user_id}/roles`"
  @spec list(Client.t(), String.t(), String.t(), map() | keyword(), keyword()) ::
          {:ok, map()} | {:error, OpenAi.Error.t()}
  def list(%Client{} = client, project_id, user_id, query \\ [], options \\ []) do
    Client.request(
      client,
      :get,
      "/projects/#{seg(project_id)}/users/#{seg(user_id)}/roles",
      Keyword.put(options, :query, query)
    )
  end

  @doc "Assigns a role to a project user. `POST /projects/{project_id}/users/{user_id}/roles`"
  @spec assign(Client.t(), String.t(), String.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def assign(%Client{} = client, project_id, user_id, body, options \\ []) when is_map(body) do
    Client.request(
      client,
      :post,
      "/projects/#{seg(project_id)}/users/#{seg(user_id)}/roles",
      Keyword.put(options, :body, body)
    )
  end

  @doc "Retrieves a project user role assignment. `GET /projects/{project_id}/users/{user_id}/roles/{role_id}`"
  @spec retrieve(Client.t(), String.t(), String.t(), String.t(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def retrieve(%Client{} = client, project_id, user_id, role_id, options \\ []) do
    Client.request(client, :get, "/projects/#{seg(project_id)}/users/#{seg(user_id)}/roles/#{seg(role_id)}", options)
  end

  @doc "Unassigns a role from a project user. `DELETE /projects/{project_id}/users/{user_id}/roles/{role_id}`"
  @spec unassign(Client.t(), String.t(), String.t(), String.t(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def unassign(%Client{} = client, project_id, user_id, role_id, options \\ []) do
    Client.request(client, :delete, "/projects/#{seg(project_id)}/users/#{seg(user_id)}/roles/#{seg(role_id)}", options)
  end

  defp seg(value), do: Client.path_segment(value)
end
