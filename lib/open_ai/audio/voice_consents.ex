defmodule OpenAi.Audio.VoiceConsents do
  @moduledoc "Client functions for custom voice consent recordings."

  alias OpenAi.{Client, Multipart}

  @doc "Uploads a voice consent recording. `POST /audio/voice_consents`"
  @spec create(Client.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def create(%Client{} = client, params, options \\ []) when is_map(params) do
    body = {:multipart, Multipart.put_files(params, [:recording])}
    Client.request(client, :post, "/audio/voice_consents", Keyword.put(options, :body, body))
  end

  @doc "Lists voice consent recordings. `GET /audio/voice_consents`"
  @spec list(Client.t(), map() | keyword(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def list(%Client{} = client, query \\ [], options \\ []) do
    Client.request(client, :get, "/audio/voice_consents", Keyword.put(options, :query, query))
  end

  @doc "Retrieves a voice consent recording. `GET /audio/voice_consents/{consent_id}`"
  @spec retrieve(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def retrieve(%Client{} = client, consent_id, options \\ []) do
    Client.request(client, :get, path(consent_id), options)
  end

  @doc "Updates a voice consent recording. `POST /audio/voice_consents/{consent_id}`"
  @spec update(Client.t(), String.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def update(%Client{} = client, consent_id, body, options \\ []) when is_map(body) do
    Client.request(client, :post, path(consent_id), Keyword.put(options, :body, body))
  end

  @doc "Deletes a voice consent recording. `DELETE /audio/voice_consents/{consent_id}`"
  @spec delete(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def delete(%Client{} = client, consent_id, options \\ []) do
    Client.request(client, :delete, path(consent_id), options)
  end

  defp path(consent_id), do: "/audio/voice_consents/#{Client.path_segment(consent_id)}"
end
