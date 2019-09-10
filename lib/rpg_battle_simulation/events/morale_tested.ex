defmodule RpgBattleSimulation.Events.MoraleTested do
  @derive Jason.Encoder
  defstruct [:uuid, :round, :battle, :attacker, :defender]
end
