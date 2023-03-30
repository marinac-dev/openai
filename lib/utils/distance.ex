defmodule Utils.Distance do
  def cosine(a, b) do
    t1 = Nx.tensor(a, type: {:f, 64})
    t2 = Nx.tensor(b, type: {:f, 64})

    norm1 =
      Nx.pow(t1, 2)
      |> Nx.sum()
      |> Nx.sqrt()

    norm2 =
      Nx.pow(t2, 2)
      |> Nx.sum()
      |> Nx.sqrt()

    Nx.dot(t1, t2)
    |> Nx.divide(Nx.dot(norm1, norm2))
    |> Nx.to_number()
    |> then(&(1 - &1))
  end
end
