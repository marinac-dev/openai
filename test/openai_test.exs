defmodule OpenaiTest do
  use ExUnit.Case
  doctest Openai

  test "greets the world" do
    assert Openai.hello() == :world
  end
end
