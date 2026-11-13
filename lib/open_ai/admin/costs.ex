defmodule OpenAi.Admin.Costs do
  @moduledoc "Organization costs. Needs an admin API key (`OpenAi.Client.new(api_key: admin_key)`)."

  alias OpenAi.Client

  @doc "Retrieves organization costs. `GET /organization/costs`"
  @spec retrieve(Client.t(), map() | keyword(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def retrieve(%Client{} = client, query \\ [], options \\ []) do
    Client.request(client, :get, "/organization/costs", Keyword.put(options, :query, query))
  end
end
