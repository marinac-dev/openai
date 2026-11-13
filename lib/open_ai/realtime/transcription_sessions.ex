defmodule OpenAi.Realtime.TranscriptionSessions do
  @moduledoc "Client functions for Realtime transcription sessions."

  alias OpenAi.Client

  @doc "Creates a Realtime transcription session. `POST /realtime/transcription_sessions`"
  @spec create(Client.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def create(%Client{} = client, body \\ %{}, options \\ []) when is_map(body) do
    Client.request(client, :post, "/realtime/transcription_sessions", Keyword.put(options, :body, body))
  end
end
