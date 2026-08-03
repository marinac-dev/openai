defmodule OpenAi.SSE.Event do
  @moduledoc "A parsed server-sent event."

  defstruct [:event, :id, :retry, data: ""]

  @type t :: %__MODULE__{
          event: String.t() | nil,
          id: String.t() | nil,
          retry: non_neg_integer() | nil,
          data: String.t()
        }
end

defmodule OpenAi.SSE do
  @moduledoc """
  Incrementally parses server-sent events across arbitrary HTTP chunk boundaries.
  """

  alias OpenAi.SSE.Event

  defstruct buffer: ""

  @type t :: %__MODULE__{buffer: String.t()}

  @spec new() :: t()
  def new, do: %__MODULE__{}

  @spec feed(t(), binary()) :: {t(), [Event.t()]}
  def feed(%__MODULE__{buffer: buffer}, chunk) when is_binary(chunk) do
    parse(buffer <> chunk, false)
  end

  @spec finish(t()) :: {t(), [Event.t()]}
  def finish(%__MODULE__{buffer: buffer}), do: parse(buffer, true)

  defp parse(data, finish?) do
    {data, trailing} = preserve_trailing_carriage_return(data, finish?)
    normalized = data |> String.replace("\r\n", "\n") |> String.replace("\r", "\n")
    normalized = if finish? and normalized != "", do: normalized <> "\n\n", else: normalized
    parts = String.split(normalized, "\n\n")
    buffer = (List.last(parts) || "") <> trailing

    events =
      parts
      |> Enum.drop(-1)
      |> Enum.reject(&(&1 == ""))
      |> Enum.map(&parse_event/1)

    {%__MODULE__{buffer: buffer}, events}
  end

  defp preserve_trailing_carriage_return(data, false) do
    if String.ends_with?(data, "\r") do
      {binary_part(data, 0, byte_size(data) - 1), "\r"}
    else
      {data, ""}
    end
  end

  defp preserve_trailing_carriage_return(data, true), do: {data, ""}

  defp parse_event(block) do
    block
    |> String.split("\n")
    |> Enum.reduce(%{event: nil, id: nil, retry: nil, data: []}, &parse_line/2)
    |> then(fn event ->
      %Event{
        event: event.event,
        id: event.id,
        retry: event.retry,
        data: Enum.reverse(event.data) |> Enum.join("\n")
      }
    end)
  end

  defp parse_line(":" <> _comment, event), do: event

  defp parse_line(line, event) do
    {field, value} =
      case String.split(line, ":", parts: 2) do
        [field, " " <> value] -> {field, value}
        [field, value] -> {field, value}
        [field] -> {field, ""}
      end

    case field do
      "event" -> %{event | event: value}
      "data" -> %{event | data: [value | event.data]}
      "id" -> %{event | id: value}
      "retry" -> %{event | retry: parse_retry(value)}
      _ -> event
    end
  end

  defp parse_retry(value) do
    case Integer.parse(value) do
      {retry, ""} when retry >= 0 -> retry
      _ -> nil
    end
  end
end
