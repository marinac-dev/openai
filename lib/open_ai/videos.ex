defmodule OpenAi.Videos do
  @moduledoc """
  Client functions for videos.

  Create, edit, extend and remix send `multipart/form-data` (the first content type in the spec);
  file fields (`input_reference`, `video`) accept a path or a `OpenAi.Multipart.file()` tuple.
  """

  alias OpenAi.Client
  alias OpenAi.Multipart

  @doc "Creates a video. `POST /videos`"
  @spec create(Client.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def create(%Client{} = client, params, options \\ []) when is_map(params) do
    multipart(client, "/videos", params, [:input_reference], options)
  end

  @doc "Lists videos. `GET /videos`"
  @spec list(Client.t(), map() | keyword(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def list(%Client{} = client, query \\ [], options \\ []) do
    Client.request(client, :get, "/videos", Keyword.put(options, :query, query))
  end

  @doc "Retrieves a video. `GET /videos/{video_id}`"
  @spec retrieve(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def retrieve(%Client{} = client, video_id, options \\ []) do
    Client.request(client, :get, path(video_id), options)
  end

  @doc "Deletes a video. `DELETE /videos/{video_id}`"
  @spec delete(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def delete(%Client{} = client, video_id, options \\ []) do
    Client.request(client, :delete, path(video_id), options)
  end

  @doc "Downloads video content, thumbnail or spritesheet (see `variant`). `GET /videos/{video_id}/content`"
  @spec content(Client.t(), String.t(), map() | keyword(), keyword()) ::
          {:ok, binary()} | {:error, OpenAi.Error.t()}
  def content(%Client{} = client, video_id, query \\ [], options \\ []) do
    options = options |> Keyword.put(:query, query) |> Keyword.put(:decode, false)
    Client.request(client, :get, path(video_id) <> "/content", options)
  end

  @doc "Creates a video remix. `POST /videos/{video_id}/remix`"
  @spec remix(Client.t(), String.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def remix(%Client{} = client, video_id, params, options \\ []) when is_map(params) do
    multipart(client, path(video_id) <> "/remix", params, [], options)
  end

  @doc "Creates a video edit. `POST /videos/edits`"
  @spec edit(Client.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def edit(%Client{} = client, params, options \\ []) when is_map(params) do
    multipart(client, "/videos/edits", params, [:video], options)
  end

  @doc "Creates a video extension. `POST /videos/extensions`"
  @spec extend(Client.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def extend(%Client{} = client, params, options \\ []) when is_map(params) do
    multipart(client, "/videos/extensions", params, [:video], options)
  end

  defp multipart(client, path, params, file_keys, options) do
    body = {:multipart, Multipart.put_files(params, file_keys)}
    Client.request(client, :post, path, Keyword.put(options, :body, body))
  end

  defp path(video_id), do: "/videos/" <> Client.path_segment(video_id)
end
