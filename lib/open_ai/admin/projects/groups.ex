defmodule OpenAi.Admin.Projects.Groups do
  @moduledoc "Project admin API: Groups. Requires an admin API key."

  alias OpenAi.Client

  @doc "Lists project groups. `GET /organization/projects/{project_id}/groups`"
  @spec list(Client.t(), String.t(), map() | keyword(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def list(%Client{} = client, project_id, query \\ [], options \\ []) do
    Client.request(
      client,
      :get,
      "/organization/projects/#{seg(project_id)}/groups",
      Keyword.put(options, :query, query)
    )
  end

  @doc "Adds a group to a project. `POST /organization/projects/{project_id}/groups`"
  @spec add(Client.t(), String.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def add(%Client{} = client, project_id, body, options \\ []) when is_map(body) do
    Client.request(client, :post, "/organization/projects/#{seg(project_id)}/groups", Keyword.put(options, :body, body))
  end

  @doc "Retrieves a project group. `GET /organization/projects/{project_id}/groups/{group_id}`"
  @spec retrieve(Client.t(), String.t(), String.t(), map() | keyword(), keyword()) ::
          {:ok, map()} | {:error, OpenAi.Error.t()}
  def retrieve(%Client{} = client, project_id, group_id, query \\ [], options \\ []) do
    Client.request(
      client,
      :get,
      "/organization/projects/#{seg(project_id)}/groups/#{seg(group_id)}",
      Keyword.put(options, :query, query)
    )
  end

  @doc "Removes a group from a project. `DELETE /organization/projects/{project_id}/groups/{group_id}`"
  @spec remove(Client.t(), String.t(), String.t(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def remove(%Client{} = client, project_id, group_id, options \\ []) do
    Client.request(client, :delete, "/organization/projects/#{seg(project_id)}/groups/#{seg(group_id)}", options)
  end

  defp seg(value), do: Client.path_segment(value)
end
