defmodule OpenAi.Admin.Projects.ServiceAccounts do
  @moduledoc "Project admin API: ServiceAccounts. Requires an admin API key."

  alias OpenAi.Client

  @doc "Lists project service accounts. `GET /organization/projects/{project_id}/service_accounts`"
  @spec list(Client.t(), String.t(), map() | keyword(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def list(%Client{} = client, project_id, query \\ [], options \\ []) do
    Client.request(
      client,
      :get,
      "/organization/projects/#{seg(project_id)}/service_accounts",
      Keyword.put(options, :query, query)
    )
  end

  @doc "Creates a project service account. `POST /organization/projects/{project_id}/service_accounts`"
  @spec create(Client.t(), String.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def create(%Client{} = client, project_id, body, options \\ []) when is_map(body) do
    Client.request(
      client,
      :post,
      "/organization/projects/#{seg(project_id)}/service_accounts",
      Keyword.put(options, :body, body)
    )
  end

  @doc "Retrieves a project service account. `GET /organization/projects/{project_id}/service_accounts/{service_account_id}`"
  @spec retrieve(Client.t(), String.t(), String.t(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def retrieve(%Client{} = client, project_id, service_account_id, options \\ []) do
    Client.request(
      client,
      :get,
      "/organization/projects/#{seg(project_id)}/service_accounts/#{seg(service_account_id)}",
      options
    )
  end

  @doc "Updates a project service account. `POST /organization/projects/{project_id}/service_accounts/{service_account_id}`"
  @spec update(Client.t(), String.t(), String.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def update(%Client{} = client, project_id, service_account_id, body, options \\ []) when is_map(body) do
    Client.request(
      client,
      :post,
      "/organization/projects/#{seg(project_id)}/service_accounts/#{seg(service_account_id)}",
      Keyword.put(options, :body, body)
    )
  end

  @doc "Deletes a project service account. `DELETE /organization/projects/{project_id}/service_accounts/{service_account_id}`"
  @spec delete(Client.t(), String.t(), String.t(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def delete(%Client{} = client, project_id, service_account_id, options \\ []) do
    Client.request(
      client,
      :delete,
      "/organization/projects/#{seg(project_id)}/service_accounts/#{seg(service_account_id)}",
      options
    )
  end

  @doc "Creates an API key for a project service account. `POST /organization/projects/{project_id}/service_accounts/{service_account_id}/api_keys`"
  @spec create_api_key(Client.t(), String.t(), String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, OpenAi.Error.t()}
  def create_api_key(%Client{} = client, project_id, service_account_id, body \\ %{}, options \\ [])
      when is_map(body) do
    Client.request(
      client,
      :post,
      "/organization/projects/#{seg(project_id)}/service_accounts/#{seg(service_account_id)}/api_keys",
      Keyword.put(options, :body, body)
    )
  end

  defp seg(value), do: Client.path_segment(value)
end
