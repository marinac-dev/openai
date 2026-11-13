defmodule OpenAi.Containers.Files do
  @moduledoc "Client functions for files inside containers."

  alias OpenAi.Client
  alias OpenAi.Multipart

  @type result :: {:ok, map()} | {:error, OpenAi.Error.t()}

  @doc "Lists container files. `GET /containers/{container_id}/files`"
  @spec list(Client.t(), String.t(), map() | keyword(), keyword()) :: result()
  def list(%Client{} = client, container_id, query \\ [], options \\ []) do
    Client.request(client, :get, files_path(container_id), Keyword.put(options, :query, query))
  end

  @doc "Creates a container file from a JSON body such as `%{file_id: ...}`. `POST /containers/{container_id}/files`"
  @spec create(Client.t(), String.t(), map(), keyword()) :: result()
  def create(%Client{} = client, container_id, body, options \\ []) when is_map(body) do
    Client.request(client, :post, files_path(container_id), Keyword.put(options, :body, body))
  end

  @doc "Uploads a container file as multipart form data with a `file` field (same endpoint as `create/4`)."
  @spec upload(Client.t(), String.t(), map(), keyword()) :: result()
  def upload(%Client{} = client, container_id, params, options \\ []) when is_map(params) do
    body = {:multipart, Multipart.put_files(params, [:file])}
    Client.request(client, :post, files_path(container_id), Keyword.put(options, :body, body))
  end

  @doc "Retrieves a container file. `GET /containers/{container_id}/files/{file_id}`"
  @spec retrieve(Client.t(), String.t(), String.t(), keyword()) :: result()
  def retrieve(%Client{} = client, container_id, file_id, options \\ []) do
    Client.request(client, :get, file_path(container_id, file_id), options)
  end

  @doc "Deletes a container file. `DELETE /containers/{container_id}/files/{file_id}`"
  @spec delete(Client.t(), String.t(), String.t(), keyword()) :: result()
  def delete(%Client{} = client, container_id, file_id, options \\ []) do
    Client.request(client, :delete, file_path(container_id, file_id), options)
  end

  @doc "Downloads container file content. `GET /containers/{container_id}/files/{file_id}/content`"
  @spec content(Client.t(), String.t(), String.t(), keyword()) :: {:ok, binary()} | {:error, OpenAi.Error.t()}
  def content(%Client{} = client, container_id, file_id, options \\ []) do
    Client.request(client, :get, file_path(container_id, file_id) <> "/content", Keyword.put(options, :decode, false))
  end

  defp files_path(container_id), do: "/containers/" <> Client.path_segment(container_id) <> "/files"
  defp file_path(container_id, file_id), do: files_path(container_id) <> "/" <> Client.path_segment(file_id)
end
