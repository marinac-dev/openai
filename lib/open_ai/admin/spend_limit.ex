defmodule OpenAi.Admin.SpendLimit do
  @moduledoc "Organization the spend limit. Needs an admin API key (`OpenAi.Client.new(api_key: admin_key)`)."

  alias OpenAi.Client

  @doc "Retrieves the organization spend limit. `GET /organization/spend_limit`"
  @spec retrieve(Client.t(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def retrieve(%Client{} = client, options \\ []) do
    Client.request(client, :get, "/organization/spend_limit", options)
  end

  @doc "Updates the organization spend limit. `POST /organization/spend_limit`"
  @spec update(Client.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def update(%Client{} = client, body, options \\ []) when is_map(body) do
    Client.request(client, :post, "/organization/spend_limit", Keyword.put(options, :body, body))
  end

  @doc "Deletes the organization spend limit. `DELETE /organization/spend_limit`"
  @spec delete(Client.t(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def delete(%Client{} = client, options \\ []) do
    Client.request(client, :delete, "/organization/spend_limit", options)
  end
end
