defmodule OpenAi.Utils.SseParser do
  @moduledoc """
  Parses a server-sent event stream into a string.
  """

  @spec parse(list()) :: String.t()
  def parse(response) do
    response
    |> Enum.reverse()
    |> Enum.join()
    |> String.split("data: ")
    |> Enum.reduce([], fn
      "", acc -> acc
      "[DONE]" <> _, acc -> acc
      line, acc -> [parse_line(line) | acc]
    end)
    |> Enum.reverse()

    # |> Enum.join()
  end

  defp parse_line(data) do
    data
    |> Jason.decode!()
    |> Map.get("choices")
    |> List.first()
    |> case do
      # * This is for streaming text responses
      %{"text" => text} -> text
      # * This is for streaming chat responses
      %{"delta" => delta} -> parse_delta(delta)
    end
  end

  # * Order matters here
  defp parse_delta(%{"function_call" => function_call}) do
    IO.inspect(function_call, label: "function_call")
    function_call
  end

  defp parse_delta(%{"content" => content}), do: content
  defp parse_delta(%{}), do: ""
end
