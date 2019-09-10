defmodule RpgBattleSimulation.Projectors.Round do
  use Commanded.Projections.Ecto, name: "round_projection"

  alias RpgBattleSimulation.{
    Events.RoundStarted,
    Events.MoraleTested,
    Projections.Round,
    Repo
  }

  project(
    %RoundStarted{
      uuid: uuid,
      battle: battle,
      round: round_number,
      attacker: attacker,
      defender: defender
    },
    _metadata,
    fn multi ->
      multi
      |> Ecto.Multi.insert(
        :round_projection,
        %Round{
          uuid: uuid,
          round: round_number,
          battle_id: battle.id,
          attacker: attacker,
          defender: defender
        }
      )
    end
  )

  project(
    %MoraleTested{
      uuid: uuid,
      attacker: attacker,
      defender: defender
    },
    _metadata,
    fn multi ->
      multi
      |> Ecto.Multi.update(
        :round_projection,
        Repo.get_by(Round, uuid: uuid)
        |> Ecto.Changeset.change(
          attacker: attacker,
          defender: defender
        )
      )
    end
  )
end
