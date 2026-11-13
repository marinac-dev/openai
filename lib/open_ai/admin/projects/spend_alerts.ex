defmodule OpenAi.Admin.Projects.SpendAlerts do
  @moduledoc "Project admin API: SpendAlerts. Requires an admin API key."

  alias OpenAi.Client

  @doc "Lists project spend alerts. `GET /organization/projects/{project_id}/spend_alerts`"
  @spec list(Client.t(), String.t(), map() | keyword(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def list(%Client{} = client, project_id, query \\ [], options \\ []) do
    Client.request(
      client,
      :get,
      "/organization/projects/#{seg(project_id)}/spend_alerts",
      Keyword.put(options, :query, query)
    )
  end

  @doc "Creates a project spend alert. `POST /organization/projects/{project_id}/spend_alerts`"
  @spec create(Client.t(), String.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def create(%Client{} = client, project_id, body, options \\ []) when is_map(body) do
    Client.request(
      client,
      :post,
      "/organization/projects/#{seg(project_id)}/spend_alerts",
      Keyword.put(options, :body, body)
    )
  end

  @doc "Retrieves a project spend alert. `GET /organization/projects/{project_id}/spend_alerts/{alert_id}`"
  @spec retrieve(Client.t(), String.t(), String.t(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def retrieve(%Client{} = client, project_id, alert_id, options \\ []) do
    Client.request(client, :get, "/organization/projects/#{seg(project_id)}/spend_alerts/#{seg(alert_id)}", options)
  end

  @doc "Updates a project spend alert. `POST /organization/projects/{project_id}/spend_alerts/{alert_id}`"
  @spec update(Client.t(), String.t(), String.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def update(%Client{} = client, project_id, alert_id, body, options \\ []) when is_map(body) do
    Client.request(
      client,
      :post,
      "/organization/projects/#{seg(project_id)}/spend_alerts/#{seg(alert_id)}",
      Keyword.put(options, :body, body)
    )
  end

  @doc "Deletes a project spend alert. `DELETE /organization/projects/{project_id}/spend_alerts/{alert_id}`"
  @spec delete(Client.t(), String.t(), String.t(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def delete(%Client{} = client, project_id, alert_id, options \\ []) do
    Client.request(client, :delete, "/organization/projects/#{seg(project_id)}/spend_alerts/#{seg(alert_id)}", options)
  end

  defp seg(value), do: Client.path_segment(value)
end
