use Mix.Config

config :rpg_battle_simulation, RpgBattleSimulation.Repo,
  database: "rpg_battle_simulation_dev",
  username: "postgres",
  hostname: "localhost",
  pool_size: 10

config :rpg_battle_simulation, ecto_repos: [RpgBattleSimulation.Repo]

config :eventstore, EventStore.Storage,
  serializer: Commanded.Serialization.JsonSerializer,
  database: "eventstore_dev",
  username: "postgres",
  hostname: "localhost",
  pool_size: 10

config :commanded,
  event_store_adapter: Commanded.EventStore.Adapters.EventStore

config :commanded_ecto_projections, repo: RpgBattleSimulation.Repo

config :logger, level: :error
