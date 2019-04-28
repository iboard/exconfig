defmodule Exconfig.MixProject do
  use Mix.Project

  def project do
    [
      app: :exconfig,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      package: package(),
      description: description(),
      deps: deps(),
      # Docs
      name: "Exconf",
      source_url: "https://github.com/iboard/exconf",
      homepage_url: "https://hexdocs.pm/exconfig",
      docs: [
        # The main page in the docs
        main: "README",
        logo: "assets/logo.png",
        extras: ["README.md", "LICENSE.md"]
      ]
    ]
  end

  def description do
    ~S"""
    Exconfig is a configuration cache reading values from `Application.get_env`
    and `System.get_env` where system overwrites application-configuration.
    """
  end

  def package do
    [
      name: "exconfig",
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["andreas@altendorfer.at"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/iboard/exconfig",
        "Documentation" => "https://hexdocs.pm/exconfig/readme.html"
      }
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Exconfig.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.19", only: :dev, runtime: false}
    ]
  end
end
