defmodule OpenAi.Admin.Projects.DataRetention do
  @moduledoc "Project admin API: DataRetention. Requires an admin API key."

  alias OpenAi.Client

  @doc "Retrieves project data retention. `GET /organization/projects/{project_id}/data_retention`"
  @spec retrieve(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def retrieve(%Client{} = client, project_id, options \\ []) do
    Client.request(client, :get, "/organization/projects/#{seg(project_id)}/data_retention", options)
  end

  @doc "Updates project data retention. `POST /organization/projects/{project_id}/data_retention`"
  @spec update(Client.t(), String.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def update(%Client{} = client, project_id, body, options \\ []) when is_map(body) do
    Client.request(
      client,
      :post,
      "/organization/projects/#{seg(project_id)}/data_retention",
      Keyword.put(options, :body, body)
    )
  end

  defp seg(value), do: Client.path_segment(value)
end
