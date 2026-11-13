defmodule OpenAi.Admin.Projects.SpendLimit do
  @moduledoc "Project admin API: SpendLimit. Requires an admin API key."

  alias OpenAi.Client

  @doc "Retrieves the project spend limit. `GET /organization/projects/{project_id}/spend_limit`"
  @spec retrieve(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def retrieve(%Client{} = client, project_id, options \\ []) do
    Client.request(client, :get, "/organization/projects/#{seg(project_id)}/spend_limit", options)
  end

  @doc "Updates the project spend limit. `POST /organization/projects/{project_id}/spend_limit`"
  @spec update(Client.t(), String.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def update(%Client{} = client, project_id, body, options \\ []) when is_map(body) do
    Client.request(
      client,
      :post,
      "/organization/projects/#{seg(project_id)}/spend_limit",
      Keyword.put(options, :body, body)
    )
  end

  @doc "Deletes the project spend limit. `DELETE /organization/projects/{project_id}/spend_limit`"
  @spec delete(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def delete(%Client{} = client, project_id, options \\ []) do
    Client.request(client, :delete, "/organization/projects/#{seg(project_id)}/spend_limit", options)
  end

  defp seg(value), do: Client.path_segment(value)
end
