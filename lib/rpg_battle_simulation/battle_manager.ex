defmodule RpgBattleSimulation.BattleManager do
  use Commanded.ProcessManagers.ProcessManager,
    name: "BattleManager",
    router: RpgBattleSimulation.Router

  alias RpgBattleSimulation.{Commands, Events}

  @derive Jason.Encoder
  defstruct [:battle_id]

  def interested?(%Events.RoundStarted{uuid: uuid}), do: {:start, uuid}
  def interested?(%Events.TacticsTested{uuid: uuid}), do: {:start, uuid}
  def interested?(%Events.MoraleTested{uuid: uuid}), do: {:start, uuid}
  def interested?(%Events.RoundEnded{id: id}), do: {:start, id}
  def interested?(_), do: false

  def handle(%__MODULE__{}, %Events.RoundStarted{
        uuid: uuid,
        round: round_number,
        battle: battle,
        attacker: attacker,
        defender: defender
      }) do
    IO.puts("Router.dispatch Command.TestTactics")

    %Commands.TestTactics{
      uuid: uuid,
      round: round_number,
      battle: battle,
      attacker: attacker,
      defender: defender
    }
  end

  def handle(%__MODULE__{}, %Events.TacticsTested{
        uuid: uuid,
        round: round_number,
        battle: battle,
        attacker: attacker,
        defender: defender
      }) do
    IO.puts("Router.dispatch Command.TestMorale")

    %Commands.TestMorale{
      uuid: uuid,
      round: round_number,
      battle: battle,
      attacker: attacker,
      defender: defender
    }
  end

  def handle(%__MODULE__{}, %Events.MoraleTested{
        battle: battle,
        attacker: attacker,
        defender: defender
      }) do
    IO.puts("Router.dispatch Command.MoraleTested")

    %Commands.EndRound{
      id: battle.id,
      attacker: attacker,
      defender: defender
    }
  end

  def handle(%__MODULE__{}, %Events.RoundEnded{
        id: id,
        attacker: %{markers: attacker_markers},
        defender: %{markers: defender_markers}
      })
      when attacker_markers == 0 or defender_markers == 0 do
    IO.puts("Router.dispatch Command.RoundEnded")

    %Commands.EndBattle{id: id}
  end

  def handle(%__MODULE__{}, %Events.RoundEnded{}) do
    IO.puts("Router.dispatch Command.RoundEnded")
    nil
  end
end
