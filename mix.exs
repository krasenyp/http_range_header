defmodule HTTPRangeParser.MixProject do
  use Mix.Project

  def project do
    [
      app: :http_range_parser,
      version: "0.0.4",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      name: "HTTP Range Parser",
      source_url: "https://github.com/krasenyp/http_range_parser"
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
      {:ex_doc, "~> 0.24", only: :dev, runtime: false}
    ]
  end

  defp description do
    "An RFC2616-compliant HTTP Range header parser."
  end

  defp package() do
    [
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/krasenyp/http_range_parser"}
    ]
  end
end
