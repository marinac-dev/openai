defmodule OpenAi.ChatKit.Sessions do
  @moduledoc "Client functions for ChatKit sessions."

  alias OpenAi.Client

  @doc "Creates a ChatKit session. `POST /chatkit/sessions`"
  @spec create(Client.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def create(%Client{} = client, body, options \\ []) when is_map(body) do
    Client.request(client, :post, "/chatkit/sessions", Keyword.put(options, :body, body))
  end

  @doc "Cancels a ChatKit session. `POST /chatkit/sessions/{session_id}/cancel`"
  @spec cancel(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def cancel(%Client{} = client, session_id, options \\ []) do
    Client.request(client, :post, "/chatkit/sessions/#{Client.path_segment(session_id)}/cancel", options)
  end
end
