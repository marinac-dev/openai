defmodule OpenAi.Admin.Projects.ModelPermissions do
  @moduledoc "Project admin API: ModelPermissions. Requires an admin API key."

  alias OpenAi.Client

  @doc "Retrieves project model permissions. `GET /organization/projects/{project_id}/model_permissions`"
  @spec retrieve(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def retrieve(%Client{} = client, project_id, options \\ []) do
    Client.request(client, :get, "/organization/projects/#{seg(project_id)}/model_permissions", options)
  end

  @doc "Updates project model permissions. `POST /organization/projects/{project_id}/model_permissions`"
  @spec update(Client.t(), String.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def update(%Client{} = client, project_id, body, options \\ []) when is_map(body) do
    Client.request(
      client,
      :post,
      "/organization/projects/#{seg(project_id)}/model_permissions",
      Keyword.put(options, :body, body)
    )
  end

  @doc "Deletes project model permissions. `DELETE /organization/projects/{project_id}/model_permissions`"
  @spec delete(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def delete(%Client{} = client, project_id, options \\ []) do
    Client.request(client, :delete, "/organization/projects/#{seg(project_id)}/model_permissions", options)
  end

  defp seg(value), do: Client.path_segment(value)
end
