defmodule RpgBattleSimulation.Regular.Battle do
  @type stats :: %{
          name: String.t(),
          tactics: list(integer()),
          leadership: list(integer()),
          army_size: integer(),
          markers: integer(),
          heroes: list()
        }

  @type t :: %__MODULE__{
          attacker: stats(),
          defender: stats(),
          result: String.t(),
          rounds: list(RpgBattleSimulation.Regular.Round.t())
        }
  defstruct [:attacker, :defender, :result, :rounds]
end
