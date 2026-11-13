defmodule OpenAi.Admin.SpendAlerts do
  @moduledoc "Organization spend alerts. Needs an admin API key (`OpenAi.Client.new(api_key: admin_key)`)."

  alias OpenAi.Client

  @doc "Lists spend alerts. `GET /organization/spend_alerts`"
  @spec list(Client.t(), map() | keyword(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def list(%Client{} = client, query \\ [], options \\ []) do
    Client.request(client, :get, "/organization/spend_alerts", Keyword.put(options, :query, query))
  end

  @doc "Creates a spend alert. `POST /organization/spend_alerts`"
  @spec create(Client.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def create(%Client{} = client, body, options \\ []) when is_map(body) do
    Client.request(client, :post, "/organization/spend_alerts", Keyword.put(options, :body, body))
  end

  @doc "Retrieves a spend alert. `GET /organization/spend_alerts/{alert_id}`"
  @spec retrieve(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def retrieve(%Client{} = client, alert_id, options \\ []) do
    Client.request(client, :get, path(alert_id), options)
  end

  @doc "Updates a spend alert. `POST /organization/spend_alerts/{alert_id}`"
  @spec update(Client.t(), String.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def update(%Client{} = client, alert_id, body, options \\ []) when is_map(body) do
    Client.request(client, :post, path(alert_id), Keyword.put(options, :body, body))
  end

  @doc "Deletes a spend alert. `DELETE /organization/spend_alerts/{alert_id}`"
  @spec delete(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def delete(%Client{} = client, alert_id, options \\ []) do
    Client.request(client, :delete, path(alert_id), options)
  end

  defp path(alert_id), do: "/organization/spend_alerts/#{Client.path_segment(alert_id)}"
end
