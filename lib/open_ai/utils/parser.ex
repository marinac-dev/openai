defmodule OpenAi.Utils.Parser do
  @moduledoc """
  Documentation for `Parser` module.

  This module is used to parse responses from OpenAI API.
  """
  require Logger

  def parse_chat_sse(data) do
    init_acc = %{
      id: nil,
      object: nil,
      created_at: nil,
      choices: [
        %{
          finish_reason: nil,
          content: [],
          function_name: nil,
          arguments: []
        }
      ],
      usage: nil
    }

    parse_sse(data, init_acc)
  end

  def parse_text_sse(data) do
    init_acc = %{
      id: nil,
      object: nil,
      created_at: nil,
      choices: [
        %{
          finish_reason: nil,
          text: []
        }
      ],
      usage: nil
    }

    %{choices: [choice]} = parsed = parse_sse(data, init_acc)
    text = choice.text |> Enum.reverse() |> Enum.join()
    %{parsed | choices: [%{choice | text: text}]}
  end

  defp parse_sse(data, init_acc) do
    data
    |> Enum.reverse()
    |> Enum.join()
    |> String.split("data: ")
    |> Enum.reduce_while(init_acc, fn
      "", acc -> {:cont, acc}
      "[DONE]" <> _, acc -> {:cont, acc}
      data, acc -> parse_data(data, acc)
    end)
  end

  defp parse_data(data, acc) do
    decoded = Jason.decode!(data)

    acc =
      acc
      |> Map.put(:id, decoded["id"])
      |> Map.put(:object, decoded["object"])
      |> Map.put(:model, decoded["model"])
      |> Map.put(:created_at, from_unix(decoded))

    decoded
    |> Map.get("choices")
    |> List.first()
    |> parse_choice(acc)
  end

  defp parse_choice(%{"finish_reason" => "function_call"}, %{choices: [choice]} = acc) do
    string = choice.arguments |> Enum.reverse() |> Enum.join() |> Jason.decode!()

    choice =
      choice
      |> Map.put(:arguments, string)
      |> Map.put(:finish_reason, :function_call)

    {:halt, Map.put(acc, :choices, [choice])}
  end

  defp parse_choice(%{"finish_reason" => "stop"}, %{choices: [%{content: content} = choice]} = acc) do
    string = content |> Enum.reverse() |> Enum.join()

    choice =
      choice
      |> Map.put(:content, string)
      |> Map.put(:finish_reason, :stop)

    {:halt, Map.put(acc, :choices, [choice])}
  end

  defp parse_choice(%{"finish_reason" => "stop"}, %{choices: [%{text: text} = choice]} = acc) do
    string = text |> Enum.reverse() |> Enum.join()

    choice =
      choice
      |> Map.put(:text, string)
      |> Map.put(:finish_reason, :stop)

    {:halt, Map.put(acc, :choices, [choice])}
  end

  defp parse_choice(%{"delta" => %{"function_call" => %{"name" => fn_name}}}, %{choices: [choice]} = acc) do
    choice = Map.put(choice, :function_name, fn_name)
    {:cont, Map.put(acc, :choices, [choice])}
  end

  defp parse_choice(
         %{"delta" => %{"function_call" => %{"arguments" => arg}}},
         %{choices: [%{arguments: args} = choice]} = acc
       ) do
    choice = Map.put(choice, :arguments, [arg | args])
    {:cont, Map.put(acc, :choices, [choice])}
  end

  # * For chat completion response
  defp parse_choice(%{"delta" => %{"content" => new_content}}, %{choices: [%{content: content} = choice]} = acc) do
    choice = Map.put(choice, :content, [new_content | content])
    {:cont, Map.put(acc, :choices, [choice])}
  end

  # * For text completion response
  defp parse_choice(%{"text" => new_content}, %{choices: [%{text: content} = choice]} = acc) do
    choice = Map.put(choice, :text, [new_content | content])
    {:cont, Map.put(acc, :choices, [choice])}
  end

  defp parse_choice(choice, acc) do
    Logger.warning("Unhandled choice: #{inspect(choice)}\n#{inspect(acc)}")
    {:cont, acc}
  end

  defp from_unix(%{"created" => timestamp}),
    do: DateTime.from_unix!(timestamp)
end
