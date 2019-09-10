defmodule RpgBattleSimulation.Application do
  use Application

  def start(_type, _args) do
    RpgBattleSimulation.Supervisor.start_link()
  end
end
