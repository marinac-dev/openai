defmodule OpenAi.Realtime.Calls do
  @moduledoc "Client functions for Realtime SIP/WebRTC calls."

  alias OpenAi.Client

  @doc """
  Creates a call from an SDP offer and returns the raw SDP answer. `POST /realtime/calls`

  `params` takes `:sdp` (string) and optionally `:session` (map, JSON-encoded, or string).
  """
  @spec create(Client.t(), map(), keyword()) :: {:ok, binary()} | {:error, OpenAi.Error.t()}
  def create(%Client{} = client, params, options \\ []) when is_map(params) do
    body = {:multipart, encode_session(params)}
    options = options |> Keyword.put(:body, body) |> Keyword.put(:decode, false)
    Client.request(client, :post, "/realtime/calls", options)
  end

  @doc "Accepts an incoming call. `POST /realtime/calls/{call_id}/accept`"
  @spec accept(Client.t(), String.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def accept(%Client{} = client, call_id, body, options \\ []) when is_map(body) do
    Client.request(client, :post, path(call_id, "accept"), Keyword.put(options, :body, body))
  end

  @doc "Hangs up a call. `POST /realtime/calls/{call_id}/hangup`"
  @spec hangup(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def hangup(%Client{} = client, call_id, options \\ []) do
    Client.request(client, :post, path(call_id, "hangup"), options)
  end

  @doc "Refers a call to another destination. `POST /realtime/calls/{call_id}/refer`"
  @spec refer(Client.t(), String.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def refer(%Client{} = client, call_id, body, options \\ []) when is_map(body) do
    Client.request(client, :post, path(call_id, "refer"), Keyword.put(options, :body, body))
  end

  @doc "Rejects an incoming call. `POST /realtime/calls/{call_id}/reject`"
  @spec reject(Client.t(), String.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def reject(%Client{} = client, call_id, body \\ %{}, options \\ []) when is_map(body) do
    Client.request(client, :post, path(call_id, "reject"), Keyword.put(options, :body, body))
  end

  defp encode_session(%{session: session} = params) when is_map(session) do
    %{params | session: Jason.encode!(session)}
  end

  defp encode_session(%{"session" => session} = params) when is_map(session) do
    %{params | "session" => Jason.encode!(session)}
  end

  defp encode_session(params), do: params

  defp path(call_id, action), do: "/realtime/calls/#{Client.path_segment(call_id)}/#{action}"
end
