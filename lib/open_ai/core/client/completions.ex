defmodule OpenAi.Core.Client.Completions do
  use OpenAi.Core.Client

  @doc false
  scope "/v1/completions"

  def chat_completion(%{stream: true} = prompt, options, :default),
    do: chat_completion(prompt, options, &default_stream_callback/2)

  def chat_completion(%{stream: true} = prompt, options, stream_callback) do
    json_data = Jason.encode!(prompt)
    conn = %{headers: nil, status: nil, body: [], type: :stream}
    stream(:post, "", json_data, options, conn, stream_callback)
  end

  def chat_completion(prompt, options, _) do
    json_data = Jason.encode!(prompt)
    post("", json_data, %{}, options)
  end

  defp default_stream_callback({:status, data}, acc), do: %{acc | status: data}
  defp default_stream_callback({:headers, headers}, acc), do: %{acc | headers: headers}
  defp default_stream_callback({:data, data}, %{body: body} = acc), do: %{acc | body: [data | body]}
end
