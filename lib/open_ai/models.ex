defmodule OpenAi.Models do
  @moduledoc "Client functions for listing, retrieving, and deleting models."

  alias OpenAi.Client

  @doc "Lists available models. `GET /models`"
  @spec list(Client.t(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def list(%Client{} = client, options \\ []), do: Client.request(client, :get, "/models", options)

  @doc "Retrieves a model. `GET /models/{model}`"
  @spec retrieve(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def retrieve(%Client{} = client, model, options \\ []) do
    Client.request(client, :get, path(model), options)
  end

  @doc "Deletes a fine-tuned model. `DELETE /models/{model}`"
  @spec delete(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def delete(%Client{} = client, model, options \\ []) do
    Client.request(client, :delete, path(model), options)
  end

  defp path(model), do: "/models/" <> Client.path_segment(model)
end
