defmodule OpenAi.LegacyChatCompletionTest do
  use ExUnit.Case, async: true

  alias OpenAi.Core.Response.ChatCompletion

  test "reassembles legacy streaming chunks before parsing events" do
    full_stream =
      event(%{"delta" => %{"content" => "Hel"}, "finish_reason" => nil}) <>
        event(%{"delta" => %{"content" => "lo"}, "finish_reason" => nil}) <>
        event(%{"delta" => %{}, "finish_reason" => "stop"}) <>
        "data: [DONE]\n\n"

    {first, rest} = String.split_at(full_stream, 31)
    {second, third} = String.split_at(rest, 47)
    buffered_chunks = Enum.reverse([first, second, third])

    assert %{choices: [%{content: "Hello", finish_reason: :stop}]} =
             ChatCompletion.parse({:ok, %{body: buffered_chunks, type: :stream}})
  end

  defp event(choice) do
    payload = %{
      "id" => "chatcmpl_123",
      "object" => "chat.completion.chunk",
      "created" => 1_700_000_000,
      "model" => "gpt-test",
      "choices" => [choice]
    }

    "data: " <> Jason.encode!(payload) <> "\n\n"
  end
end
