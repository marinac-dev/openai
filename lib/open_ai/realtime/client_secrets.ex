defmodule OpenAi.Realtime.ClientSecrets do
  @moduledoc "Client functions for Realtime client secrets."

  alias OpenAi.Client

  @doc "Creates a Realtime client secret. `POST /realtime/client_secrets`"
  @spec create(Client.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def create(%Client{} = client, body \\ %{}, options \\ []) when is_map(body) do
    Client.request(client, :post, "/realtime/client_secrets", Keyword.put(options, :body, body))
  end
end
