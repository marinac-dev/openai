defmodule OpenAi.Core.Response do
  @moduledoc false

  @callback parse(term()) :: term()
end
