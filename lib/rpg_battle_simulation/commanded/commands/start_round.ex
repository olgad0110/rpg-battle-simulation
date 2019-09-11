defmodule RpgBattleSimulation.Commanded.Commands.StartRound do
  defstruct [:uuid, :battle_id, :attacker_modifier, :defender_modifier]
end
