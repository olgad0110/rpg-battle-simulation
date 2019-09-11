defmodule RpgBattleSimulation.Commanded.Projections.Round do
  use Ecto.Schema

  schema "round_projections" do
    field(:uuid, :string)
    field(:battle_id, :integer)
    field(:round, :integer)
    field(:attacker, :map)
    field(:defender, :map)
  end
end
