defmodule OpenAi.Realtime.Translations do
  @moduledoc "Client functions for Realtime translations."

  alias OpenAi.Client

  @doc "Creates a Realtime translation client secret. `POST /realtime/translations/client_secrets`"
  @spec create_client_secret(Client.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def create_client_secret(%Client{} = client, body \\ %{}, options \\ []) when is_map(body) do
    Client.request(client, :post, "/realtime/translations/client_secrets", Keyword.put(options, :body, body))
  end
end
