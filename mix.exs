defmodule Arrows.MixProject do
  use Mix.Project

  def project do
    [
      app: :arrows,
      version: "0.2.1",
      elixir: "~> 1.12",
      description: "A handful of (mostly) arrow macros",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end

  defp package do
    [
      name: :arrows,
      files: ~w(lib mix.exs README.md),
      maintainers: ["Bonfire Networks"],
      licenses: ["Apache 2.0"],
      links: %{
        "Github" => "http://github.com/bonfire-networks/arrows",
        "Docs" => "http://hexdocs.pm/arrows"
      }
    ]
  end
end
