defmodule OpenAi.Admin.Projects.HostedToolPermissions do
  @moduledoc "Project admin API: HostedToolPermissions. Requires an admin API key."

  alias OpenAi.Client

  @doc "Retrieves project hosted tool permissions. `GET /organization/projects/{project_id}/hosted_tool_permissions`"
  @spec retrieve(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def retrieve(%Client{} = client, project_id, options \\ []) do
    Client.request(client, :get, "/organization/projects/#{seg(project_id)}/hosted_tool_permissions", options)
  end

  @doc "Updates project hosted tool permissions. `POST /organization/projects/{project_id}/hosted_tool_permissions`"
  @spec update(Client.t(), String.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def update(%Client{} = client, project_id, body, options \\ []) when is_map(body) do
    Client.request(
      client,
      :post,
      "/organization/projects/#{seg(project_id)}/hosted_tool_permissions",
      Keyword.put(options, :body, body)
    )
  end

  defp seg(value), do: Client.path_segment(value)
end
