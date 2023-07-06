defmodule OpenAi.Core.Response.ChatCompletion do
  @moduledoc """
  Documentation for `ChatCompletion` response.
  """
  require Logger
  @behaviour OpenAi.Core.Response

  @enforce_keys [:id, :object, :created_at, :choices, :usage]
  defstruct [:id, :object, :created_at, :choices, :usage, :model]

  @type t :: %__MODULE__{
          id: String.t(),
          object: String.t(),
          # NOTE: Returned field is created, but we rename it to created_at
          created_at: DateTime.t(),
          choices: list(map()),
          usage: list(map()),
          model: String.t()
        }

  # * For parsing streaming SSE responses
  @impl true
  def parse({:ok, %{body: body, type: :stream}}) do
    response = %{
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
      usage: []
    }

    body
    |> Enum.join()
    |> String.split("data: ")
    |> Enum.reverse()
    |> Enum.reduce_while(response, fn
      "", acc -> {:cont, acc}
      "[DONE]" <> _, acc -> {:cont, acc}
      data, acc -> parse_data(data, acc)
    end)
  end

  # * For parsing HTTP responses
  @impl true
  def parse({:ok, %{body: body}}) do
    case Jason.decode(body) do
      {:ok, decoded} ->
        opts =
          decoded
          |> Enum.reduce(%{}, fn {k, v}, acc ->
            Map.put(acc, String.to_atom(k), v)
          end)
          |> Map.delete(:created)
          |> Map.put(:created_at, from_unix(decoded))

        {:ok, struct(__MODULE__, opts)}

      {:error, _} ->
        {:error, "Invalid response body"}
    end
  end

  defp from_unix(%{"created" => timestamp}),
    do: DateTime.from_unix!(timestamp)

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

  defp parse_choice(%{"finish_reason" => "stop"}, %{choices: [choice]} = acc) do
    string = choice.content |> Enum.reverse() |> Enum.join()

    choice =
      choice
      |> Map.put(:content, string)
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

  defp parse_choice(%{"delta" => %{"content" => new_content}}, %{choices: [%{content: content} = choice]} = acc) do
    choice = Map.put(choice, :content, [new_content | content])
    {:cont, Map.put(acc, :choices, [choice])}
  end

  defp parse_choice(choice, acc) do
    Logger.warning("Unhandled choice: #{inspect(choice)}")
    {:cont, acc}
  end
end
