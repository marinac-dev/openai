defmodule OpenAi.ContentProvenance do
  @moduledoc "Client functions for content provenance checks."

  alias OpenAi.{Client, Multipart}

  @doc "Checks a file for OpenAI provenance signals. `POST /content_provenance_checks`"
  @spec check(Client.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def check(%Client{} = client, params, options \\ []) when is_map(params) do
    body = {:multipart, Multipart.put_files(params, [:file])}
    Client.request(client, :post, "/content_provenance_checks", Keyword.put(options, :body, body))
  end
end
