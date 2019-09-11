defmodule RpgBattleSimulation.Commanded.Events.RoundEnded do
  @derive Jason.Encoder
  defstruct [:id, :attacker, :defender, :next_round_number]
end
