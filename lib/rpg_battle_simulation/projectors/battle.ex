defmodule RpgBattleSimulation.Projectors.Battle do
  use Commanded.Projections.Ecto, name: "battle_projection"

  alias RpgBattleSimulation.{
    Events.BattleStarted,
    Events.RoundEnded,
    Events.BattleEnded,
    Projections.Battle,
    Repo
  }

  project(
    %BattleStarted{
      id: id,
      next_round_number: next_round_number,
      attacker: attacker,
      defender: defender
    },
    _metadata,
    fn multi ->
      multi
      |> Ecto.Multi.insert(:battle_projection, %Battle{
        id: id,
        next_round_number: next_round_number,
        attacker: attacker,
        defender: defender
      })
    end
  )

  project(
    %RoundEnded{
      id: id,
      next_round_number: next_round_number,
      attacker: attacker,
      defender: defender
    },
    _metadata,
    fn multi ->
      multi
      |> Ecto.Multi.update(
        :battle_projection,
        Repo.get_by(Battle, id: id)
        |> Ecto.Changeset.change(
          next_round_number: next_round_number,
          attacker: attacker,
          defender: defender
        )
      )
    end
  )

  project(
    %BattleEnded{
      id: id,
      result: result
    },
    _metadata,
    fn multi ->
      multi
      |> Ecto.Multi.update(
        :battle_projection,
        Repo.get_by(Battle, id: id)
        |> Ecto.Changeset.change(result: result)
      )
    end
  )
end
