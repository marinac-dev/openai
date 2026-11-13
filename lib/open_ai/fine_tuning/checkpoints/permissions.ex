defmodule OpenAi.FineTuning.Checkpoints.Permissions do
  @moduledoc "Client functions for fine-tuned model checkpoint permissions."

  alias OpenAi.Client

  @type result :: {:ok, map()} | {:error, OpenAi.Error.t()}

  @doc "Lists checkpoint permissions. `GET /fine_tuning/checkpoints/{fine_tuned_model_checkpoint}/permissions`"
  @spec list(Client.t(), String.t(), map() | keyword(), keyword()) :: result()
  def list(%Client{} = client, checkpoint, query \\ [], options \\ []) do
    Client.request(client, :get, base(checkpoint), Keyword.put(options, :query, query))
  end

  @doc "Creates checkpoint permissions. `POST /fine_tuning/checkpoints/{fine_tuned_model_checkpoint}/permissions`"
  @spec create(Client.t(), String.t(), map(), keyword()) :: result()
  def create(%Client{} = client, checkpoint, body, options \\ []) when is_map(body) do
    Client.request(client, :post, base(checkpoint), Keyword.put(options, :body, body))
  end

  @doc """
  Deletes a checkpoint permission. `DELETE /fine_tuning/checkpoints/{fine_tuned_model_checkpoint}/permissions/{permission_id}`
  """
  @spec delete(Client.t(), String.t(), String.t(), keyword()) :: result()
  def delete(%Client{} = client, checkpoint, permission_id, options \\ []) do
    Client.request(client, :delete, base(checkpoint) <> "/" <> Client.path_segment(permission_id), options)
  end

  defp base(checkpoint), do: "/fine_tuning/checkpoints/" <> Client.path_segment(checkpoint) <> "/permissions"
end
