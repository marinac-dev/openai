defmodule OpenAi.Videos.Characters do
  @moduledoc "Client functions for video characters."

  alias OpenAi.Client
  alias OpenAi.Multipart

  @doc "Creates a video character from an uploaded video. `POST /videos/characters`"
  @spec create(Client.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def create(%Client{} = client, params, options \\ []) when is_map(params) do
    body = {:multipart, Multipart.put_files(params, [:video])}
    Client.request(client, :post, "/videos/characters", Keyword.put(options, :body, body))
  end

  @doc "Retrieves a video character. `GET /videos/characters/{character_id}`"
  @spec retrieve(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def retrieve(%Client{} = client, character_id, options \\ []) do
    Client.request(client, :get, "/videos/characters/" <> Client.path_segment(character_id), options)
  end
end
