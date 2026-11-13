defmodule OpenAi.Files do
  @moduledoc "Client functions for uploading and managing files."

  alias OpenAi.{Client, Multipart}

  @doc "Lists files. `GET /files`"
  @spec list(Client.t(), map() | keyword(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def list(%Client{} = client, query \\ [], options \\ []) do
    Client.request(client, :get, "/files", Keyword.put(options, :query, query))
  end

  @doc "Uploads a file. `POST /files`"
  @spec create(Client.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def create(%Client{} = client, params, options \\ []) when is_map(params) do
    body = {:multipart, Multipart.put_files(params, [:file])}
    Client.request(client, :post, "/files", Keyword.put(options, :body, body))
  end

  @doc "Retrieves a file. `GET /files/{file_id}`"
  @spec retrieve(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def retrieve(%Client{} = client, file_id, options \\ []) do
    Client.request(client, :get, path(file_id), options)
  end

  @doc "Deletes a file. `DELETE /files/{file_id}`"
  @spec delete(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def delete(%Client{} = client, file_id, options \\ []) do
    Client.request(client, :delete, path(file_id), options)
  end

  @doc "Downloads file content as a raw binary. `GET /files/{file_id}/content`"
  @spec content(Client.t(), String.t(), keyword()) :: {:ok, binary()} | {:error, OpenAi.Error.t()}
  def content(%Client{} = client, file_id, options \\ []) do
    Client.request(client, :get, path(file_id) <> "/content", Keyword.put(options, :decode, false))
  end

  defp path(file_id), do: "/files/" <> Client.path_segment(file_id)
end
