defmodule OpenAi.Audio do
  @moduledoc "Client functions for speech generation, transcription, and translation."

  alias OpenAi.{Client, Multipart}

  @doc "Generates speech audio. `POST /audio/speech`"
  @spec speech(Client.t(), map(), keyword()) :: {:ok, binary()} | {:error, OpenAi.Error.t()}
  def speech(%Client{} = client, body, options \\ []) when is_map(body) do
    options = options |> Keyword.put(:body, body) |> Keyword.put(:decode, false)
    Client.request(client, :post, "/audio/speech", options)
  end

  @spec stream_speech(Client.t(), map(), (map() -> term()), keyword()) ::
          {:ok, OpenAi.Response.t()} | {:error, OpenAi.Error.t()}
  def stream_speech(%Client{} = client, body, on_event, options \\ []) when is_map(body) do
    body = put_field(body, :stream_format, "sse")
    Client.stream(client, :post, "/audio/speech", on_event, Keyword.put(options, :body, body))
  end

  @doc "Transcribes audio. `POST /audio/transcriptions`"
  @spec transcribe(Client.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def transcribe(%Client{} = client, params, options \\ []) when is_map(params) do
    multipart_request(client, "/audio/transcriptions", params, options)
  end

  @spec stream_transcription(Client.t(), map(), (map() -> term()), keyword()) ::
          {:ok, OpenAi.Response.t()} | {:error, OpenAi.Error.t()}
  def stream_transcription(%Client{} = client, params, on_event, options \\ []) when is_map(params) do
    params = put_field(params, :stream, true)
    body = {:multipart, Multipart.put_files(params, [:file])}
    Client.stream(client, :post, "/audio/transcriptions", on_event, Keyword.put(options, :body, body))
  end

  @doc "Translates audio into English. `POST /audio/translations`"
  @spec translate(Client.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def translate(%Client{} = client, params, options \\ []) when is_map(params) do
    multipart_request(client, "/audio/translations", params, options)
  end

  @doc "Creates a custom voice. `POST /audio/voices`"
  @spec create_voice(Client.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def create_voice(%Client{} = client, params, options \\ []) when is_map(params) do
    body = {:multipart, Multipart.put_files(params, [:audio_sample])}
    Client.request(client, :post, "/audio/voices", Keyword.put(options, :body, body))
  end

  defp multipart_request(client, path, params, options) do
    body = {:multipart, Multipart.put_files(params, [:file])}
    Client.request(client, :post, path, Keyword.put(options, :body, body))
  end

  defp put_field(map, key, value) do
    if Map.has_key?(map, Atom.to_string(key)) do
      Map.put(map, Atom.to_string(key), value)
    else
      Map.put(map, key, value)
    end
  end
end
