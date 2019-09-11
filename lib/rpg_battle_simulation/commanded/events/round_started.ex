defmodule RpgBattleSimulation.Commanded.Events.RoundStarted do
  @derive Jason.Encoder
  defstruct [:uuid, :round, :battle, :attacker, :defender]
end
