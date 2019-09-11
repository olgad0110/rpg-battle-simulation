defmodule RpgBattleSimulation.Commanded.Events.BattleEnded do
  @derive Jason.Encoder
  defstruct [:id, :result]
end
