defmodule OpenAi.Admin.Projects.RateLimits do
  @moduledoc "Project admin API: RateLimits. Requires an admin API key."

  alias OpenAi.Client

  @doc "Lists project rate limits. `GET /organization/projects/{project_id}/rate_limits`"
  @spec list(Client.t(), String.t(), map() | keyword(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def list(%Client{} = client, project_id, query \\ [], options \\ []) do
    Client.request(
      client,
      :get,
      "/organization/projects/#{seg(project_id)}/rate_limits",
      Keyword.put(options, :query, query)
    )
  end

  @doc "Updates a project rate limit. `POST /organization/projects/{project_id}/rate_limits/{rate_limit_id}`"
  @spec update(Client.t(), String.t(), String.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def update(%Client{} = client, project_id, rate_limit_id, body, options \\ []) when is_map(body) do
    Client.request(
      client,
      :post,
      "/organization/projects/#{seg(project_id)}/rate_limits/#{seg(rate_limit_id)}",
      Keyword.put(options, :body, body)
    )
  end

  defp seg(value), do: Client.path_segment(value)
end
