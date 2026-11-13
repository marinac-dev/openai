defmodule OpenAi.Skills do
  @moduledoc "Client functions for skills."

  alias OpenAi.Client
  alias OpenAi.Multipart

  @doc """
  Creates a skill. `POST /skills`

  Sends `multipart/form-data`; `files` may be one file or a list of files.
  """
  @spec create(Client.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def create(%Client{} = client, params, options \\ []) when is_map(params) do
    body = {:multipart, Multipart.put_files(params, [:files])}
    Client.request(client, :post, "/skills", Keyword.put(options, :body, body))
  end

  @doc "Lists skills. `GET /skills`"
  @spec list(Client.t(), map() | keyword(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def list(%Client{} = client, query \\ [], options \\ []) do
    Client.request(client, :get, "/skills", Keyword.put(options, :query, query))
  end

  @doc "Retrieves a skill. `GET /skills/{skill_id}`"
  @spec retrieve(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def retrieve(%Client{} = client, skill_id, options \\ []) do
    Client.request(client, :get, path(skill_id), options)
  end

  @doc "Updates the default version pointer of a skill. `POST /skills/{skill_id}`"
  @spec update(Client.t(), String.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def update(%Client{} = client, skill_id, body \\ %{}, options \\ []) when is_map(body) do
    Client.request(client, :post, path(skill_id), Keyword.put(options, :body, body))
  end

  @doc "Deletes a skill. `DELETE /skills/{skill_id}`"
  @spec delete(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def delete(%Client{} = client, skill_id, options \\ []) do
    Client.request(client, :delete, path(skill_id), options)
  end

  @doc "Downloads the default version of a skill as a zip. `GET /skills/{skill_id}/content`"
  @spec content(Client.t(), String.t(), keyword()) :: {:ok, binary()} | {:error, OpenAi.Error.t()}
  def content(%Client{} = client, skill_id, options \\ []) do
    Client.request(client, :get, path(skill_id) <> "/content", Keyword.put(options, :decode, false))
  end

  defp path(skill_id), do: "/skills/" <> Client.path_segment(skill_id)
end
