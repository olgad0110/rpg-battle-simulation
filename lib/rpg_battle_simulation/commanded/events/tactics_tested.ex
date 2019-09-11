defmodule RpgBattleSimulation.Commanded.Events.TacticsTested do
  @derive Jason.Encoder
  defstruct [:uuid, :round, :battle, :attacker, :defender]
end
