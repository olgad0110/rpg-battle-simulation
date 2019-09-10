defmodule RpgBattleSimulation.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    [
      {RpgBattleSimulation.Repo, []},
      worker(RpgBattleSimulation.Projectors.Battle, [], id: :battle_projector),
      worker(RpgBattleSimulation.Projectors.Round, [], id: :round_projector),
      worker(RpgBattleSimulation.BattleManager, [[start_from: :current]])
    ]
    |> Supervisor.init(strategy: :one_for_one)
  end
end
