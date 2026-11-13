defmodule OpenAi.Admin.AuditLogs do
  @moduledoc "Organization audit logs. Needs an admin API key (`OpenAi.Client.new(api_key: admin_key)`)."

  alias OpenAi.Client

  @doc "Lists audit logs. `GET /organization/audit_logs`"
  @spec list(Client.t(), map() | keyword(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def list(%Client{} = client, query \\ [], options \\ []) do
    Client.request(client, :get, "/organization/audit_logs", Keyword.put(options, :query, query))
  end
end
