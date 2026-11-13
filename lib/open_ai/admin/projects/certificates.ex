defmodule OpenAi.Admin.Projects.Certificates do
  @moduledoc "Project admin API: Certificates. Requires an admin API key."

  alias OpenAi.Client

  @doc "Lists project certificates. `GET /organization/projects/{project_id}/certificates`"
  @spec list(Client.t(), String.t(), map() | keyword(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def list(%Client{} = client, project_id, query \\ [], options \\ []) do
    Client.request(
      client,
      :get,
      "/organization/projects/#{seg(project_id)}/certificates",
      Keyword.put(options, :query, query)
    )
  end

  @doc "Activates project certificates. `POST /organization/projects/{project_id}/certificates/activate`"
  @spec activate(Client.t(), String.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def activate(%Client{} = client, project_id, body, options \\ []) when is_map(body) do
    Client.request(
      client,
      :post,
      "/organization/projects/#{seg(project_id)}/certificates/activate",
      Keyword.put(options, :body, body)
    )
  end

  @doc "Deactivates project certificates. `POST /organization/projects/{project_id}/certificates/deactivate`"
  @spec deactivate(Client.t(), String.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def deactivate(%Client{} = client, project_id, body, options \\ []) when is_map(body) do
    Client.request(
      client,
      :post,
      "/organization/projects/#{seg(project_id)}/certificates/deactivate",
      Keyword.put(options, :body, body)
    )
  end

  defp seg(value), do: Client.path_segment(value)
end
