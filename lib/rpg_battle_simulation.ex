defmodule RpgBattleSimulation do
  alias RpgBattleSimulation.{
    Aggregates.Battle,
    Commands.StartBattle,
    Commands.StartRound,
    Projections.Battle,
    Projections.Round,
    Repo,
    Router
  }

  import Ecto.Query

  def get_battle(id) do
    Repo.get(Battle, id)
  end

  def get_battle_last_round(id) do
    from(r in Round,
      where: r.battle_id == ^id,
      order_by: [desc: :round],
      limit: 1
    )
    |> Repo.one()
  end

  def start(id, attacker \\ nil, defender \\ nil) do
    IO.puts("Router.dispatch Command.StartBattle")

    %StartBattle{
      id: id,
      attacker: attacker || attacker_data(),
      defender: defender || defender_data()
    }
    |> Router.dispatch()
  end

  def next_round(battle_id, attacker_modifier \\ 0, defender_modifier \\ 0) do
    IO.puts("Router.dispatch Command.StartRound")

    %StartRound{
      uuid: UUID.uuid4(),
      battle_id: battle_id,
      attacker_modifier: attacker_modifier,
      defender_modifier: defender_modifier
    }
    |> Router.dispatch()
  end

  defp attacker_data do
    %{name: "BG", tactics: [2, 1], leadership: [2, 1], army_size: 100_000}
  end

  defp defender_data do
    %{name: "N", tactics: [3, 2], leadership: [3, 2], army_size: 90_000}
  end
end
