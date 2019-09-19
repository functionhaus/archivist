defmodule Archivist.MixProject do
  use Mix.Project

  @version "0.2.2"
  @description "Plain-text, version-controlled blogging in Arcdown and Markdown."

  def project do
    [
      app: :archivist,
      name: "Archivist",
      version: @version,
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      build_embedded: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env),
      deps: deps(),
      description: @description,
      package: package(),
      source_url: "https://github.com/functionhaus/archivist",
      homepage_url: "https://functionhaus.com",
      docs: [
        logo: "assets/functionhaus_logo.png",
        extras: ["README.md"],
        main: "readme",
        source_ref: "v#{@version}",
        source_url: "https://github.com/functionhaus/archivist"
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  defp deps do
    [
      {:arcdown, "~> 0.1"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
     files: ["lib", "mix.exs", "README.md"],
     maintainers: ["FunctionHaus LLC, Mike Zazaian"],
     licenses: ["Apache 2"],
     links: %{"GitHub" => "https://github.com/functionhaus/archivist",
              "Docs" => "https://hexdocs.pm/archivist/"}
     ]
  end
end
