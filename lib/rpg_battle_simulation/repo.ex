defmodule RpgBattleSimulation.Repo do
  use Ecto.Repo,
    otp_app: :rpg_battle_simulation,
    adapter: Ecto.Adapters.Postgres
end
