defmodule OpenAi.Realtime.Sessions do
  @moduledoc "Client functions for Realtime sessions."

  alias OpenAi.Client

  @doc "Creates a Realtime session. `POST /realtime/sessions`"
  @spec create(Client.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def create(%Client{} = client, body \\ %{}, options \\ []) when is_map(body) do
    Client.request(client, :post, "/realtime/sessions", Keyword.put(options, :body, body))
  end
end
