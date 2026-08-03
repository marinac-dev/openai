defmodule OpenAi.SSETest do
  use ExUnit.Case, async: true

  alias OpenAi.SSE

  test "parses comments, metadata, multiline data, and a trailing event" do
    parser = SSE.new()
    {parser, []} = SSE.feed(parser, ": keepalive\nid: event-1\nretry: 500\ndata: first")
    {parser, [event]} = SSE.feed(parser, " line\ndata: second line\n\n")

    assert event.id == "event-1"
    assert event.retry == 500
    assert event.data == "first line\nsecond line"

    {parser, []} = SSE.feed(parser, "event: completed\ndata: {}")
    {_parser, [trailing]} = SSE.finish(parser)
    assert trailing.event == "completed"
    assert trailing.data == "{}"
  end

  test "does not split an event when CRLF is divided between chunks" do
    parser = SSE.new()
    {parser, []} = SSE.feed(parser, "event: delta\r")
    {parser, []} = SSE.feed(parser, "\ndata: {\"delta\":\"hello\"}\r")
    {_parser, [event]} = SSE.feed(parser, "\n\r\n")

    assert event.event == "delta"
    assert event.data == ~s({"delta":"hello"})
  end
end
