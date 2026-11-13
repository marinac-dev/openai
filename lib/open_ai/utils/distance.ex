defmodule OpenAi.Utils.Distance do
  @moduledoc "Functions for calculating the distance between vectors."

  @doc """
  Calculates the cosine distance (`1 - cosine similarity`) between two equal-length numeric vectors.

  Raises `ArithmeticError` when either vector has zero magnitude.

  ## Examples

      OpenAi.Utils.Distance.cosine([1, 2, 3], [4, 5, 6])
      #=> approximately 0.0253681538
  """
  @spec cosine([number()], [number()]) :: float()
  def cosine(a, b) when is_list(a) and is_list(b) do
    dot = dot(a, b)
    1 - dot / (:math.sqrt(dot(a, a)) * :math.sqrt(dot(b, b)))
  end

  defp dot(a, b), do: a |> Enum.zip(b) |> Enum.reduce(0.0, fn {x, y}, sum -> sum + x * y end)
end
