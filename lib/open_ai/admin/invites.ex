defmodule OpenAi.Admin.Invites do
  @moduledoc "Organization invites. Needs an admin API key (`OpenAi.Client.new(api_key: admin_key)`)."

  alias OpenAi.Client

  @doc "Lists invites. `GET /organization/invites`"
  @spec list(Client.t(), map() | keyword(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def list(%Client{} = client, query \\ [], options \\ []) do
    Client.request(client, :get, "/organization/invites", Keyword.put(options, :query, query))
  end

  @doc "Creates an invite. `POST /organization/invites`"
  @spec create(Client.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def create(%Client{} = client, body, options \\ []) when is_map(body) do
    Client.request(client, :post, "/organization/invites", Keyword.put(options, :body, body))
  end

  @doc "Retrieves an invite. `GET /organization/invites/{invite_id}`"
  @spec retrieve(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def retrieve(%Client{} = client, invite_id, options \\ []) do
    Client.request(client, :get, path(invite_id), options)
  end

  @doc "Deletes an invite. `DELETE /organization/invites/{invite_id}`"
  @spec delete(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def delete(%Client{} = client, invite_id, options \\ []) do
    Client.request(client, :delete, path(invite_id), options)
  end

  defp path(invite_id), do: "/organization/invites/#{Client.path_segment(invite_id)}"
end
