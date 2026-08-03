defmodule OpenAiTest do
  use ExUnit.Case
  doctest OpenAi

  test "greets the world" do
    assert OpenAi.hello() == :world
  end
end
