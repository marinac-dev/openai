defmodule OpenAi.Embeddings do
  @moduledoc "Client functions for the Embeddings API."

  alias OpenAi.Client

  @doc "Creates embeddings. `POST /embeddings`"
  @spec create(Client.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def create(%Client{} = client, body, options \\ []) when is_map(body) do
    Client.request(client, :post, "/embeddings", Keyword.put(options, :body, body))
  end
end
