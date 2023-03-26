defmodule OpenAi.Embedding do
  @moduledoc """
  A client for interacting with the OpenAI Embedding API.
  """

  use OpenAi.Core.Client

  scope "/v1/embeddings"

  def post_ada_002(input) do
    message =
      input
      |> format_body("text-embedding-ada-002")
      |> Jason.encode!()

    post "", message, []
  end

  defp format_body(input, model) do
    %{
      input: input,
      model: model
    }
  end
end
