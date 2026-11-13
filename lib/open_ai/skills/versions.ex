defmodule OpenAi.Skills.Versions do
  @moduledoc "Client functions for skill versions."

  alias OpenAi.Client
  alias OpenAi.Multipart

  @doc """
  Creates a skill version. `POST /skills/{skill_id}/versions`

  Sends `multipart/form-data`; `files` may be one file or a list of files.
  """
  @spec create(Client.t(), String.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def create(%Client{} = client, skill_id, params, options \\ []) when is_map(params) do
    body = {:multipart, Multipart.put_files(params, [:files])}
    Client.request(client, :post, base_path(skill_id), Keyword.put(options, :body, body))
  end

  @doc "Lists skill versions. `GET /skills/{skill_id}/versions`"
  @spec list(Client.t(), String.t(), map() | keyword(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def list(%Client{} = client, skill_id, query \\ [], options \\ []) do
    Client.request(client, :get, base_path(skill_id), Keyword.put(options, :query, query))
  end

  @doc "Retrieves a skill version. `GET /skills/{skill_id}/versions/{version}`"
  @spec retrieve(Client.t(), String.t(), String.t() | integer(), keyword()) ::
          {:ok, map()} | {:error, OpenAi.Error.t()}
  def retrieve(%Client{} = client, skill_id, version, options \\ []) do
    Client.request(client, :get, path(skill_id, version), options)
  end

  @doc "Deletes a skill version. `DELETE /skills/{skill_id}/versions/{version}`"
  @spec delete(Client.t(), String.t(), String.t() | integer(), keyword()) ::
          {:ok, map()} | {:error, OpenAi.Error.t()}
  def delete(%Client{} = client, skill_id, version, options \\ []) do
    Client.request(client, :delete, path(skill_id, version), options)
  end

  @doc "Downloads a skill version as a zip. `GET /skills/{skill_id}/versions/{version}/content`"
  @spec content(Client.t(), String.t(), String.t() | integer(), keyword()) ::
          {:ok, binary()} | {:error, OpenAi.Error.t()}
  def content(%Client{} = client, skill_id, version, options \\ []) do
    Client.request(client, :get, path(skill_id, version) <> "/content", Keyword.put(options, :decode, false))
  end

  defp base_path(skill_id), do: "/skills/" <> Client.path_segment(skill_id) <> "/versions"

  defp path(skill_id, version), do: base_path(skill_id) <> "/" <> Client.path_segment(version)
end
