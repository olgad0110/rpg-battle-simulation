defmodule RpgBattleSimulation.Commanded.Aggregates.Round do
  alias RpgBattleSimulation.Commanded.{
    Aggregates.Battle,
    Commands.StartRound,
    Commands.TestTactics,
    Commands.TestMorale,
    Events.RoundStarted,
    Events.TacticsTested,
    Events.MoraleTested,
    Projections
  }

  alias RpgBattleSimulation.{Commanded, RpgRules}

  @type stats :: %{
          tactics_modifier: integer(),
          morale_modifier: integer(),
          next_round_modifier: integer(),
          markers_lost: integer()
        }

  @type t :: %__MODULE__{
          uuid: String.t(),
          round: integer(),
          attacker: stats(),
          defender: stats(),
          battle: Battle.t()
        }
  defstruct [:uuid, :round, :attacker, :defender, :battle]

  def execute(%__MODULE__{uuid: nil}, %StartRound{
        uuid: uuid,
        battle_id: battle_id,
        attacker_modifier: attacker_modifier,
        defender_modifier: defender_modifier
      }) do
    battle =
      Commanded.get_battle(battle_id)
      |> Projections.Battle.to_aggregate()

    {attacker_last_round_mod, defender_last_round_mod} =
      case Commanded.get_battle_last_round(battle_id) do
        nil ->
          {0, 0}

        %{attacker: attacker, defender: defender} ->
          {attacker["next_round_modifier"], defender["next_round_modifier"]}
      end

    case battle.result do
      nil ->
        {attacker_tactics_modifier, defender_tactics_modifier} =
          RpgRules.calculate_round_modifiers(
            {battle.attacker[:markers], attacker_modifier + attacker_last_round_mod},
            {battle.defender[:markers], defender_modifier + defender_last_round_mod}
          )

        %RoundStarted{
          uuid: uuid,
          round: battle.next_round_number,
          battle: battle,
          attacker: %{tactics_modifier: attacker_tactics_modifier},
          defender: %{tactics_modifier: defender_tactics_modifier}
        }

      _ ->
        {:error, :battle_already_finished}
    end
  end

  def execute(%__MODULE__{}, %TestTactics{
        uuid: uuid,
        round: round_number,
        battle: battle,
        attacker: attacker,
        defender: defender
      }) do
    {defender_markers_lost, attacker_morale_modifier} =
      RpgRules.test_tactics(battle.attacker[:tactics], attacker[:tactics_modifier])

    {attacker_markers_lost, defender_morale_modifier} =
      RpgRules.test_tactics(battle.defender[:tactics], defender[:tactics_modifier])

    %TacticsTested{
      uuid: uuid,
      round: round_number,
      battle: battle,
      attacker:
        attacker
        |> Map.put(:morale_modifier, attacker_morale_modifier)
        |> Map.put(:markers_lost, attacker_markers_lost),
      defender:
        defender
        |> Map.put(:morale_modifier, defender_morale_modifier)
        |> Map.put(:markers_lost, defender_markers_lost)
    }
  end

  def execute(%__MODULE__{}, %TestMorale{
        uuid: uuid,
        round: round_number,
        battle: battle,
        attacker: attacker,
        defender: defender
      }) do
    attacker_next_round_modifier =
      RpgRules.test_morale(
        battle.attacker[:leadership],
        attacker[:morale_modifier],
        attacker[:markers_lost],
        defender[:markers_lost]
      )

    defender_next_round_modifier =
      RpgRules.test_morale(
        battle.defender[:leadership],
        defender[:morale_modifier],
        defender[:markers_lost],
        attacker[:markers_lost]
      )

    %MoraleTested{
      uuid: uuid,
      round: round_number,
      battle: battle,
      attacker: attacker |> Map.put(:next_round_modifier, attacker_next_round_modifier),
      defender: defender |> Map.put(:next_round_modifier, defender_next_round_modifier)
    }
  end

  def apply(%__MODULE__{} = battle_round, %RoundStarted{
        uuid: uuid,
        round: round_number,
        battle: battle,
        attacker: attacker,
        defender: defender
      }) do
    IO.puts("Event.RoundStarted")

    %__MODULE__{
      battle_round
      | uuid: uuid,
        round: round_number,
        battle: battle,
        attacker: attacker,
        defender: defender
    }
  end

  def apply(%__MODULE__{} = battle_round, %TacticsTested{
        attacker: attacker,
        defender: defender
      }) do
    IO.puts("Event.TacticsTested")

    %__MODULE__{battle_round | attacker: attacker, defender: defender}
  end

  def apply(%__MODULE__{} = battle_round, %MoraleTested{
        attacker: attacker,
        defender: defender
      }) do
    IO.puts("Event.MoraleTested")

    %__MODULE__{battle_round | attacker: attacker, defender: defender}
  end
end
