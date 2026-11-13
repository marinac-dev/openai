defmodule OpenAi.Uploads do
  @moduledoc "Client functions for multipart file uploads."

  alias OpenAi.{Client, Multipart}

  @doc "Creates an upload. `POST /uploads`"
  @spec create(Client.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def create(%Client{} = client, body, options \\ []) when is_map(body) do
    Client.request(client, :post, "/uploads", Keyword.put(options, :body, body))
  end

  @doc "Adds a part to an upload. `POST /uploads/{upload_id}/parts`"
  @spec add_part(Client.t(), String.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def add_part(%Client{} = client, upload_id, params, options \\ []) when is_map(params) do
    body = {:multipart, Multipart.put_files(params, [:data])}
    Client.request(client, :post, path(upload_id) <> "/parts", Keyword.put(options, :body, body))
  end

  @doc "Completes an upload. `POST /uploads/{upload_id}/complete`"
  @spec complete(Client.t(), String.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def complete(%Client{} = client, upload_id, body, options \\ []) when is_map(body) do
    Client.request(client, :post, path(upload_id) <> "/complete", Keyword.put(options, :body, body))
  end

  @doc "Cancels an upload. `POST /uploads/{upload_id}/cancel`"
  @spec cancel(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def cancel(%Client{} = client, upload_id, options \\ []) do
    Client.request(client, :post, path(upload_id) <> "/cancel", options)
  end

  defp path(upload_id), do: "/uploads/#{Client.path_segment(upload_id)}"
end
