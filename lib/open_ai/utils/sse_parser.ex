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
      data, acc -> [parse_data(data) | acc]
    end)
    |> Enum.reverse()
    |> Enum.join()
  end

  defp parse_data(data) do
    data
    |> Jason.decode!()
    |> Map.get("choices")
    |> List.first()
    |> case do
      %{"text" => text} -> text
      %{"delta" => delta} -> parse_delta(delta)
    end
  end

  defp parse_delta(%{"role" => "assistant"}), do: ""
  defp parse_delta(%{"content" => content}), do: content
  defp parse_delta(%{}), do: ""
end
