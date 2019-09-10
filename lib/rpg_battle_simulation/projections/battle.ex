defmodule RpgBattleSimulation.Projections.Battle do
  use Ecto.Schema

  schema "battle_projections" do
    field(:attacker, :map)
    field(:defender, :map)
    field(:result, :string)
    field(:next_round_number, :integer)
  end

  def to_aggregate(%__MODULE__{
        id: id,
        result: result,
        next_round_number: next_round_number,
        attacker: attacker,
        defender: defender
      }) do
    %RpgBattleSimulation.Aggregates.Battle{
      id: id,
      result: result,
      next_round_number: next_round_number,
      attacker: keys_to_atoms(attacker),
      defender: keys_to_atoms(defender)
    }
  end

  defp keys_to_atoms(map), do: Map.new(map, fn {k, v} -> {String.to_atom(k), v} end)
end
