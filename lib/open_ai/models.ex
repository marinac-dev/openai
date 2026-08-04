defmodule OpenAi.Models do
  @moduledoc "Client functions for listing, retrieving, and deleting models."

  alias OpenAi.Client

  @spec list(Client.t(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def list(%Client{} = client, options \\ []), do: Client.request(client, :get, "/models", options)

  @spec retrieve(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def retrieve(%Client{} = client, model, options \\ []) do
    Client.request(client, :get, path(model), options)
  end

  @spec delete(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def delete(%Client{} = client, model, options \\ []) do
    Client.request(client, :delete, path(model), options)
  end

  @doc false
  def list_models, do: list(Client.new())

  @doc false
  def retrieve_model(model), do: retrieve(Client.new(), model)

  defp path(model), do: "/models/" <> Client.path_segment(model)
end
