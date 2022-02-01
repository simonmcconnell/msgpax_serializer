defmodule MsgpaxSerializer.MixProject do
  use Mix.Project

  @version "0.1.0"
  @github_url "https://github.com/simonmcconnell/msgpax_serializer"

  def project do
    [
      app: :msgpax_serializer,
      version: @version,
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      docs: [
        source_url: @github_url,
        source_ref: "v#{@version}",
        main: "readme",
        extras: ["README.md"]
      ]
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:msgpax, "~> 2.0", optional: true},
      {:phoenix, "~> 1.3", only: [:dev, :test]},
      {:jason, "~> 1.0", only: [:dev, :test]},
      {:phoenix_gen_socket_client, "~> 4.0", only: [:dev, :test]},
      {:websocket_client, "~> 1.2", only: [:dev, :test]},
      {:ex_doc, "~> 0.28", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      links: %{
        "GitHub" => @github_url,
        "Msgpax" => "https://github.com/lexmag/msgpax",
        "phoenix_gen_socket_client" => "https://github.com/J0/phoenix_gen_socket_client"
      },
      licenses: ["MIT"]
    ]
  end
end
