defmodule OpenAi.Containers do
  @moduledoc "Client functions for containers."

  alias OpenAi.Client

  @type result :: {:ok, map()} | {:error, OpenAi.Error.t()}

  @doc "Lists containers. `GET /containers`"
  @spec list(Client.t(), map() | keyword(), keyword()) :: result()
  def list(%Client{} = client, query \\ [], options \\ []) do
    Client.request(client, :get, "/containers", Keyword.put(options, :query, query))
  end

  @doc "Creates a container. `POST /containers`"
  @spec create(Client.t(), map(), keyword()) :: result()
  def create(%Client{} = client, body, options \\ []) when is_map(body) do
    Client.request(client, :post, "/containers", Keyword.put(options, :body, body))
  end

  @doc "Retrieves a container. `GET /containers/{container_id}`"
  @spec retrieve(Client.t(), String.t(), keyword()) :: result()
  def retrieve(%Client{} = client, container_id, options \\ []) do
    Client.request(client, :get, path(container_id), options)
  end

  @doc "Deletes a container. `DELETE /containers/{container_id}`"
  @spec delete(Client.t(), String.t(), keyword()) :: result()
  def delete(%Client{} = client, container_id, options \\ []) do
    Client.request(client, :delete, path(container_id), options)
  end

  defp path(container_id), do: "/containers/" <> Client.path_segment(container_id)
end
