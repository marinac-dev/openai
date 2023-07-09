defmodule OpenAi.Core.Response do
  @moduledoc """
  Structure for parsing OpenAI API responses
  """

  @callback parse({:ok, %Finch.Response{}}) :: struct()
  @callback parse({:error, map()}) :: {:error, map()}
end
