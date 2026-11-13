defmodule OpenAi.Admin.Projects.Roles do
  @moduledoc "Project admin API: Roles. Requires an admin API key."

  alias OpenAi.Client

  @doc "Lists project roles. `GET /projects/{project_id}/roles`"
  @spec list(Client.t(), String.t(), map() | keyword(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def list(%Client{} = client, project_id, query \\ [], options \\ []) do
    Client.request(client, :get, "/projects/#{seg(project_id)}/roles", Keyword.put(options, :query, query))
  end

  @doc "Creates a project role. `POST /projects/{project_id}/roles`"
  @spec create(Client.t(), String.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def create(%Client{} = client, project_id, body, options \\ []) when is_map(body) do
    Client.request(client, :post, "/projects/#{seg(project_id)}/roles", Keyword.put(options, :body, body))
  end

  @doc "Retrieves a project role. `GET /projects/{project_id}/roles/{role_id}`"
  @spec retrieve(Client.t(), String.t(), String.t(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def retrieve(%Client{} = client, project_id, role_id, options \\ []) do
    Client.request(client, :get, "/projects/#{seg(project_id)}/roles/#{seg(role_id)}", options)
  end

  @doc "Updates a project role. `POST /projects/{project_id}/roles/{role_id}`"
  @spec update(Client.t(), String.t(), String.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def update(%Client{} = client, project_id, role_id, body, options \\ []) when is_map(body) do
    Client.request(
      client,
      :post,
      "/projects/#{seg(project_id)}/roles/#{seg(role_id)}",
      Keyword.put(options, :body, body)
    )
  end

  @doc "Deletes a project role. `DELETE /projects/{project_id}/roles/{role_id}`"
  @spec delete(Client.t(), String.t(), String.t(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def delete(%Client{} = client, project_id, role_id, options \\ []) do
    Client.request(client, :delete, "/projects/#{seg(project_id)}/roles/#{seg(role_id)}", options)
  end

  defp seg(value), do: Client.path_segment(value)
end
