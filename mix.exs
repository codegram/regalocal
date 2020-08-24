defmodule Regalocal.MixProject do
  use Mix.Project

  def project do
    [
      app: :regalocal,
      version: "0.1.0",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Regalocal.Application, []},
      extra_applications: [:logger, :runtime_tools, :peerage, :inets]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:ci), do: elixirc_paths(:test)
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.5.0-rc.0", override: true},
      {:phoenix_pubsub, "~> 2.0"},
      {:phoenix_ecto, "~> 4.0"},
      {:phoenix_live_dashboard, "~> 0.1"},
      {:phoenix_live_view, "~> 0.12.0"},
      {:telemetry_poller, "~> 0.4"},
      {:telemetry_metrics, "~> 0.4"},
      {:floki, ">= 0.0.0"},
      {:ecto_sql, "~> 3.1"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_pubsub_redis, "~> 3.0"},
      {:phoenix_live_dashboard, "~> 0.2.0"},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.1"},
      {:plug_cowboy, "~> 2.1"},
      {:veil, "~> 0.2"},
      {:gen_smtp, "~> 0.15.0"},
      {:geocoder, "~> 1.0"},
      {:geo, "~> 3.0"},
      {:geo_postgis, "~> 3.1"},
      {:cloudex, "~> 1.4.1"},
      {:faker, "~> 0.13"},
      {:ecto_enum, "~> 1.4"},
      {:sentry, "~> 7.0"},
      {:premailex, "~> 0.3.0"},
      {:peerage, "~> 1.0"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run -e \"Regalocal.Seeds.seed!\""],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
