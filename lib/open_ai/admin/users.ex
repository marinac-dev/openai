defmodule OpenAi.Admin.Users do
  @moduledoc "Organization users. Needs an admin API key (`OpenAi.Client.new(api_key: admin_key)`)."

  alias OpenAi.Client

  @doc "Lists users. `GET /organization/users`"
  @spec list(Client.t(), map() | keyword(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def list(%Client{} = client, query \\ [], options \\ []) do
    Client.request(client, :get, "/organization/users", Keyword.put(options, :query, query))
  end

  @doc "Retrieves a user. `GET /organization/users/{user_id}`"
  @spec retrieve(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def retrieve(%Client{} = client, user_id, options \\ []) do
    Client.request(client, :get, path(user_id), options)
  end

  @doc "Modifies a user. `POST /organization/users/{user_id}`"
  @spec update(Client.t(), String.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def update(%Client{} = client, user_id, body, options \\ []) when is_map(body) do
    Client.request(client, :post, path(user_id), Keyword.put(options, :body, body))
  end

  @doc "Deletes a user. `DELETE /organization/users/{user_id}`"
  @spec delete(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def delete(%Client{} = client, user_id, options \\ []) do
    Client.request(client, :delete, path(user_id), options)
  end

  defp path(user_id), do: "/organization/users/#{Client.path_segment(user_id)}"
end
