defmodule OpenAi.Utils.DistanceTest do
  use ExUnit.Case, async: true

  alias OpenAi.Utils.Distance

  test "cosine distance of two vectors" do
    assert_in_delta Distance.cosine([1, 2, 3], [4, 5, 6]), 0.025368153802923787, 1.0e-12
  end

  test "identical and orthogonal vectors" do
    assert_in_delta Distance.cosine([1.0, 2.0], [1.0, 2.0]), 0.0, 1.0e-12
    assert_in_delta Distance.cosine([1, 0], [0, 1]), 1.0, 1.0e-12
  end
end
