defmodule OpenAi.Admin.Projects do
  @moduledoc "Project admin API: projects. Requires an admin API key."

  alias OpenAi.Client

  @doc "Lists projects. `GET /organization/projects`"
  @spec list(Client.t(), map() | keyword(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def list(%Client{} = client, query \\ [], options \\ []) do
    Client.request(client, :get, "/organization/projects", Keyword.put(options, :query, query))
  end

  @doc "Creates a project. `POST /organization/projects`"
  @spec create(Client.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def create(%Client{} = client, body, options \\ []) when is_map(body) do
    Client.request(client, :post, "/organization/projects", Keyword.put(options, :body, body))
  end

  @doc "Retrieves a project. `GET /organization/projects/{project_id}`"
  @spec retrieve(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def retrieve(%Client{} = client, project_id, options \\ []) do
    Client.request(client, :get, "/organization/projects/#{seg(project_id)}", options)
  end

  @doc "Updates a project. `POST /organization/projects/{project_id}`"
  @spec update(Client.t(), String.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def update(%Client{} = client, project_id, body, options \\ []) when is_map(body) do
    Client.request(client, :post, "/organization/projects/#{seg(project_id)}", Keyword.put(options, :body, body))
  end

  @doc "Archives a project. `POST /organization/projects/{project_id}/archive`"
  @spec archive(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def archive(%Client{} = client, project_id, options \\ []) do
    Client.request(client, :post, "/organization/projects/#{seg(project_id)}/archive", options)
  end

  defp seg(value), do: Client.path_segment(value)
end
