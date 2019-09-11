defmodule RpgBattleSimulation.MixProject do
  use Mix.Project

  def project do
    [
      app: :rpg_battle_simulation,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :eventstore, :ecto],
      mod: {RpgBattleSimulation.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:commanded, "~> 0.19"},
      {:jason, "~> 1.1"},
      {:commanded_eventstore_adapter, "~> 0.6"},
      {:eventstore, "~> 0.17"},
      {:ecto_sql, "~> 3.0"},
      {:postgrex, ">= 0.0.0"},
      {:commanded_ecto_projections, "~> 0.8"},
      {:flow, "~> 0.14"}
    ]
  end

  defp aliases do
    [
      test: [
        "ecto.drop",
        "event_store.drop",
        "ecto.create",
        "ecto.migrate",
        "event_store.create",
        "event_store.init",
        "test"
      ]
    ]
  end
end
