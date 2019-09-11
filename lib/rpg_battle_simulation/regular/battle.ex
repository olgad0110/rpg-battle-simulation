defmodule RpgBattleSimulation.Regular.Battle do
  @type stats :: %{
          name: String.t(),
          tactics: list(integer()),
          leadership: list(integer()),
          army_size: integer(),
          markers: integer()
        }

  @type t :: %__MODULE__{
          attacker: stats(),
          defender: stats(),
          result: :attacker_won | :defender_won | :draw,
          rounds: list(RpgBattleSimulation.Regular.Round.t())
        }
  defstruct [:attacker, :defender, :result, :rounds]
end
