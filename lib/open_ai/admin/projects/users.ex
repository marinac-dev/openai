defmodule OpenAi.Admin.Projects.Users do
  @moduledoc "Project admin API: Users. Requires an admin API key."

  alias OpenAi.Client

  @doc "Lists project users. `GET /organization/projects/{project_id}/users`"
  @spec list(Client.t(), String.t(), map() | keyword(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def list(%Client{} = client, project_id, query \\ [], options \\ []) do
    Client.request(client, :get, "/organization/projects/#{seg(project_id)}/users", Keyword.put(options, :query, query))
  end

  @doc "Creates a project user. `POST /organization/projects/{project_id}/users`"
  @spec create(Client.t(), String.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def create(%Client{} = client, project_id, body, options \\ []) when is_map(body) do
    Client.request(client, :post, "/organization/projects/#{seg(project_id)}/users", Keyword.put(options, :body, body))
  end

  @doc "Retrieves a project user. `GET /organization/projects/{project_id}/users/{user_id}`"
  @spec retrieve(Client.t(), String.t(), String.t(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def retrieve(%Client{} = client, project_id, user_id, options \\ []) do
    Client.request(client, :get, "/organization/projects/#{seg(project_id)}/users/#{seg(user_id)}", options)
  end

  @doc "Updates a project user. `POST /organization/projects/{project_id}/users/{user_id}`"
  @spec update(Client.t(), String.t(), String.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def update(%Client{} = client, project_id, user_id, body, options \\ []) when is_map(body) do
    Client.request(
      client,
      :post,
      "/organization/projects/#{seg(project_id)}/users/#{seg(user_id)}",
      Keyword.put(options, :body, body)
    )
  end

  @doc "Deletes a project user. `DELETE /organization/projects/{project_id}/users/{user_id}`"
  @spec delete(Client.t(), String.t(), String.t(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def delete(%Client{} = client, project_id, user_id, options \\ []) do
    Client.request(client, :delete, "/organization/projects/#{seg(project_id)}/users/#{seg(user_id)}", options)
  end

  defp seg(value), do: Client.path_segment(value)
end
