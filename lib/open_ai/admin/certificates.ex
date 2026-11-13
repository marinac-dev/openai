defmodule OpenAi.Admin.Certificates do
  @moduledoc "Organization certificates. Needs an admin API key (`OpenAi.Client.new(api_key: admin_key)`)."

  alias OpenAi.Client

  @doc "Lists organization certificates. `GET /organization/certificates`"
  @spec list(Client.t(), map() | keyword(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def list(%Client{} = client, query \\ [], options \\ []) do
    Client.request(client, :get, "/organization/certificates", Keyword.put(options, :query, query))
  end

  @doc "Uploads a certificate. `POST /organization/certificates`"
  @spec create(Client.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def create(%Client{} = client, body, options \\ []) when is_map(body) do
    Client.request(client, :post, "/organization/certificates", Keyword.put(options, :body, body))
  end

  @doc "Activates certificates for the organization. `POST /organization/certificates/activate`"
  @spec activate(Client.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def activate(%Client{} = client, body, options \\ []) when is_map(body) do
    Client.request(client, :post, "/organization/certificates/activate", Keyword.put(options, :body, body))
  end

  @doc "Deactivates certificates for the organization. `POST /organization/certificates/deactivate`"
  @spec deactivate(Client.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def deactivate(%Client{} = client, body, options \\ []) when is_map(body) do
    Client.request(client, :post, "/organization/certificates/deactivate", Keyword.put(options, :body, body))
  end

  @doc "Retrieves a certificate. `GET /organization/certificates/{certificate_id}`"
  @spec retrieve(Client.t(), String.t(), map() | keyword(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def retrieve(%Client{} = client, certificate_id, query \\ [], options \\ []) do
    Client.request(client, :get, path(certificate_id), Keyword.put(options, :query, query))
  end

  @doc "Modifies a certificate. `POST /organization/certificates/{certificate_id}`"
  @spec update(Client.t(), String.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def update(%Client{} = client, certificate_id, body, options \\ []) when is_map(body) do
    Client.request(client, :post, path(certificate_id), Keyword.put(options, :body, body))
  end

  @doc "Deletes a certificate. `DELETE /organization/certificates/{certificate_id}`"
  @spec delete(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def delete(%Client{} = client, certificate_id, options \\ []) do
    Client.request(client, :delete, path(certificate_id), options)
  end

  defp path(certificate_id), do: "/organization/certificates/#{Client.path_segment(certificate_id)}"
end
