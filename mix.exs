defmodule OpenAi.MixProject do
  use Mix.Project

  def project do
    [
      app: :openai,
      version: "0.0.1",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {OpenAi, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.29.2", only: :dev},
      {:finch, "~> 0.15.0"},
      {:idna, "~> 6.0"},
      {:castore, "~> 0.1"},
      {:nx, "~> 0.5.2"},
      # * Code quality
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false}
    ]
  end
end
