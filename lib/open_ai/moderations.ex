defmodule OpenAi.Moderations do
  @moduledoc "Client functions for the Moderations API."

  alias OpenAi.Client

  @spec create(Client.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def create(%Client{} = client, body, options \\ []) when is_map(body) do
    Client.request(client, :post, "/moderations", Keyword.put(options, :body, body))
  end
end
