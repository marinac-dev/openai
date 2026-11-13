defmodule OpenAi.Admin.Projects.Groups.Roles do
  @moduledoc "Project admin API: Groups.Roles. Requires an admin API key."

  alias OpenAi.Client

  @doc "Lists group role assignments. `GET /projects/{project_id}/groups/{group_id}/roles`"
  @spec list(Client.t(), String.t(), String.t(), map() | keyword(), keyword()) ::
          {:ok, map()} | {:error, OpenAi.Error.t()}
  def list(%Client{} = client, project_id, group_id, query \\ [], options \\ []) do
    Client.request(
      client,
      :get,
      "/projects/#{seg(project_id)}/groups/#{seg(group_id)}/roles",
      Keyword.put(options, :query, query)
    )
  end

  @doc "Assigns a role to a project group. `POST /projects/{project_id}/groups/{group_id}/roles`"
  @spec assign(Client.t(), String.t(), String.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def assign(%Client{} = client, project_id, group_id, body, options \\ []) when is_map(body) do
    Client.request(
      client,
      :post,
      "/projects/#{seg(project_id)}/groups/#{seg(group_id)}/roles",
      Keyword.put(options, :body, body)
    )
  end

  @doc "Retrieves a project group role assignment. `GET /projects/{project_id}/groups/{group_id}/roles/{role_id}`"
  @spec retrieve(Client.t(), String.t(), String.t(), String.t(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def retrieve(%Client{} = client, project_id, group_id, role_id, options \\ []) do
    Client.request(client, :get, "/projects/#{seg(project_id)}/groups/#{seg(group_id)}/roles/#{seg(role_id)}", options)
  end

  @doc "Unassigns a role from a project group. `DELETE /projects/{project_id}/groups/{group_id}/roles/{role_id}`"
  @spec unassign(Client.t(), String.t(), String.t(), String.t(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def unassign(%Client{} = client, project_id, group_id, role_id, options \\ []) do
    Client.request(
      client,
      :delete,
      "/projects/#{seg(project_id)}/groups/#{seg(group_id)}/roles/#{seg(role_id)}",
      options
    )
  end

  defp seg(value), do: Client.path_segment(value)
end
