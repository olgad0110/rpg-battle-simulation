defmodule RpgBattleSimulation.Regular.Round do
  @type stats :: %{
          tactics_modifier: integer(),
          morale_modifier: integer(),
          next_round_modifier: integer(),
          markers_lost: integer()
        }

  @type t :: %__MODULE__{
          attacker: stats(),
          defender: stats()
        }
  defstruct [:attacker, :defender]
end
