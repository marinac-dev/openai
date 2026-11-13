defmodule OpenAi.Admin.DataRetention do
  @moduledoc "Organization data retention settings. Needs an admin API key (`OpenAi.Client.new(api_key: admin_key)`)."

  alias OpenAi.Client

  @doc "Retrieves organization data retention. `GET /organization/data_retention`"
  @spec retrieve(Client.t(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def retrieve(%Client{} = client, options \\ []) do
    Client.request(client, :get, "/organization/data_retention", options)
  end

  @doc "Updates organization data retention. `POST /organization/data_retention`"
  @spec update(Client.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def update(%Client{} = client, body, options \\ []) when is_map(body) do
    Client.request(client, :post, "/organization/data_retention", Keyword.put(options, :body, body))
  end
end
