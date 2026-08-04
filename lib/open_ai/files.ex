defmodule OpenAi.Files do
  @moduledoc "Client functions for uploading and managing files."

  alias OpenAi.{Client, Multipart}

  @spec list(Client.t(), map() | keyword(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def list(%Client{} = client, query \\ [], options \\ []) do
    Client.request(client, :get, "/files", Keyword.put(options, :query, query))
  end

  @spec create(Client.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def create(%Client{} = client, params, options \\ []) when is_map(params) do
    multipart = params |> mark_file(:file) |> mark_file("file") |> Multipart.build()
    Client.request(client, :post, "/files", Keyword.put(options, :body, {:multipart, multipart}))
  end

  @spec retrieve(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def retrieve(%Client{} = client, file_id, options \\ []) do
    Client.request(client, :get, path(file_id), options)
  end

  @spec delete(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def delete(%Client{} = client, file_id, options \\ []) do
    Client.request(client, :delete, path(file_id), options)
  end

  @spec content(Client.t(), String.t(), keyword()) :: {:ok, binary()} | {:error, OpenAi.Error.t()}
  def content(%Client{} = client, file_id, options \\ []) do
    Client.request(client, :get, path(file_id) <> "/content", Keyword.put(options, :decode, false))
  end

  @doc false
  def list_files, do: list(Client.new())

  @doc false
  def upload_file({file_path, purpose}, options \\ []) do
    create(Client.new(), %{file: file_path, purpose: purpose}, options)
  end

  @doc false
  def delete_file(file_id), do: delete(Client.new(), file_id)

  @doc false
  def retrieve_file(file_id), do: retrieve(Client.new(), file_id)

  @doc false
  def retrieve_file_content(file_id), do: content(Client.new(), file_id)

  defp mark_file(params, key) do
    case Map.fetch(params, key) do
      {:ok, {:file, _path}} -> params
      {:ok, path} -> Map.put(params, key, {:file, path})
      :error -> params
    end
  end

  defp path(file_id), do: "/files/" <> Client.path_segment(file_id)
end
