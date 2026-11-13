defmodule OpenAi.Admin.Projects.ApiKeys do
  @moduledoc "Project admin API: ApiKeys. Requires an admin API key."

  alias OpenAi.Client

  @doc "Lists project API keys. `GET /organization/projects/{project_id}/api_keys`"
  @spec list(Client.t(), String.t(), map() | keyword(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def list(%Client{} = client, project_id, query \\ [], options \\ []) do
    Client.request(
      client,
      :get,
      "/organization/projects/#{seg(project_id)}/api_keys",
      Keyword.put(options, :query, query)
    )
  end

  @doc "Retrieves a project API key. `GET /organization/projects/{project_id}/api_keys/{api_key_id}`"
  @spec retrieve(Client.t(), String.t(), String.t(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def retrieve(%Client{} = client, project_id, api_key_id, options \\ []) do
    Client.request(client, :get, "/organization/projects/#{seg(project_id)}/api_keys/#{seg(api_key_id)}", options)
  end

  @doc "Deletes a project API key. `DELETE /organization/projects/{project_id}/api_keys/{api_key_id}`"
  @spec delete(Client.t(), String.t(), String.t(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def delete(%Client{} = client, project_id, api_key_id, options \\ []) do
    Client.request(client, :delete, "/organization/projects/#{seg(project_id)}/api_keys/#{seg(api_key_id)}", options)
  end

  defp seg(value), do: Client.path_segment(value)
end
