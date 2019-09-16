defmodule RpgBattleSimulation.Regular do
  alias RpgBattleSimulation.{Regular.Battle, Regular.Round, RpgRules}

  @attacker_data %{
    name: "BG",
    tactics: [2, 1],
    leadership: [2, 1],
    army_size: 100_000,
    heroes: [[4, 3], [3, 2]]
  }
  @defender_data %{
    name: "N",
    tactics: [3, 2],
    leadership: [3, 2],
    army_size: 90_000,
    heroes: [[4, 4], [3, 3]]
  }

  def start(attacker_data \\ nil, defender_data \\ nil) do
    attacker = attacker_data || @attacker_data
    defender = defender_data || @defender_data

    {attacker_markers, defender_markers} =
      RpgRules.calculate_battle_markers(attacker[:army_size], defender[:army_size])

    %Battle{
      attacker: Map.put(attacker, :markers, attacker_markers),
      defender: Map.put(defender, :markers, defender_markers),
      rounds: []
    }
  end

  def next_round(battle, attacker_modifier \\ 0, defender_modifier \\ 0)

  def next_round(%Battle{result: result}, _, _) when not is_nil(result),
    do: {:error, :battle_already_finished}

  def next_round(%Battle{} = battle, attacker_modifier, defender_modifier) do
    battle
    |> initialize_round(attacker_modifier, defender_modifier)
    |> test_tactics()
    |> test_morale()
    |> finish_round()
    |> maybe_finish_battle()
  end

  defp initialize_round(
         %Battle{rounds: [last_round | _] = previous_rounds} = battle,
         attacker_modifier,
         defender_modifier
       ) do
    {attacker_tactics_modifier, defender_tactics_modifier} =
      RpgRules.calculate_round_modifiers(
        {battle.attacker[:markers],
         attacker_modifier + last_round.attacker[:next_round_modifier]},
        {battle.defender[:markers], defender_modifier + last_round.defender[:next_round_modifier]}
      )

    attacker_hero_modifier =
      RpgRules.calculate_hero_modifiers(battle.attacker[:heroes], attacker_tactics_modifier)

    defender_hero_modifier =
      RpgRules.calculate_hero_modifiers(battle.defender[:heroes], defender_tactics_modifier)

    current_round = %Round{
      attacker: %{tactics_modifier: attacker_tactics_modifier + attacker_hero_modifier},
      defender: %{tactics_modifier: defender_tactics_modifier + defender_hero_modifier}
    }

    %{battle | rounds: [current_round | previous_rounds]}
  end

  defp initialize_round(
         %Battle{rounds: previous_rounds} = battle,
         attacker_modifier,
         defender_modifier
       ) do
    {attacker_tactics_modifier, defender_tactics_modifier} =
      RpgRules.calculate_round_modifiers(
        {battle.attacker[:markers], attacker_modifier},
        {battle.defender[:markers], defender_modifier}
      )

    current_round = %Round{
      attacker: %{tactics_modifier: attacker_tactics_modifier},
      defender: %{tactics_modifier: defender_tactics_modifier}
    }

    %{battle | rounds: [current_round | previous_rounds]}
  end

  defp test_tactics(%Battle{rounds: [current_round | previous_rounds]} = battle) do
    {defender_markers_lost, attacker_morale_modifier} =
      RpgRules.test_tactics(battle.attacker[:tactics], current_round.attacker[:tactics_modifier])

    {attacker_markers_lost, defender_morale_modifier} =
      RpgRules.test_tactics(battle.defender[:tactics], current_round.defender[:tactics_modifier])

    current_round = %{
      current_round
      | attacker:
          current_round.attacker
          |> Map.put(:morale_modifier, attacker_morale_modifier)
          |> Map.put(:markers_lost, attacker_markers_lost),
        defender:
          current_round.defender
          |> Map.put(:morale_modifier, defender_morale_modifier)
          |> Map.put(:markers_lost, defender_markers_lost)
    }

    %{battle | rounds: [current_round | previous_rounds]}
  end

  defp test_morale(%Battle{rounds: [current_round | previous_rounds]} = battle) do
    attacker_next_round_modifier =
      RpgRules.test_morale(
        battle.attacker[:leadership],
        current_round.attacker[:morale_modifier],
        current_round.attacker[:markers_lost],
        current_round.defender[:markers_lost]
      )

    defender_next_round_modifier =
      RpgRules.test_morale(
        battle.defender[:leadership],
        current_round.defender[:morale_modifier],
        current_round.defender[:markers_lost],
        current_round.attacker[:markers_lost]
      )

    current_round = %{
      current_round
      | attacker:
          current_round.attacker |> Map.put(:next_round_modifier, attacker_next_round_modifier),
        defender:
          current_round.defender |> Map.put(:next_round_modifier, defender_next_round_modifier)
    }

    %{battle | rounds: [current_round | previous_rounds]}
  end

  defp finish_round(%Battle{rounds: [current_round | _previous_rounds]} = battle) do
    %{
      battle
      | attacker:
          Map.put(
            battle.attacker,
            :markers,
            battle.attacker[:markers] - current_round.attacker[:markers_lost]
          ),
        defender:
          Map.put(
            battle.defender,
            :markers,
            battle.defender[:markers] - current_round.defender[:markers_lost]
          )
    }
  end

  defp maybe_finish_battle(
         %Battle{attacker: %{markers: attacker_markers}, defender: %{markers: defender_markers}} =
           battle
       )
       when attacker_markers <= 0 or defender_markers <= 0 do
    %{battle | result: RpgRules.compute_battle_result(attacker_markers, defender_markers)}
  end

  defp maybe_finish_battle(%Battle{rounds: all_rounds} = battle) when length(all_rounds) >= 100 do
    %{battle | result: "draw"}
  end

  defp maybe_finish_battle(%Battle{} = battle), do: battle
end
