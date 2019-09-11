defmodule RpgBattleSimulation.Commanded.Router do
  use Commanded.Commands.Router
  alias RpgBattleSimulation.Commanded.{Aggregates.Battle, Aggregates.Round, Commands}

  dispatch(Commands.StartBattle, to: Battle, identity: :id)
  dispatch(Commands.EndRound, to: Battle, identity: :id)
  dispatch(Commands.EndBattle, to: Battle, identity: :id)

  dispatch(Commands.StartRound, to: Round, identity: :uuid)
  dispatch(Commands.TestTactics, to: Round, identity: :uuid)
  dispatch(Commands.TestMorale, to: Round, identity: :uuid)
end
