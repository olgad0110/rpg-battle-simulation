defmodule RpgBattleSimulation.RegularTest do
  use ExUnit.Case
  alias RpgBattleSimulation.Regular.{Battle, Round}
  alias RpgBattleSimulation.Regular

  test "flow of simulation" do
    battle = Regular.start()

    assert %Battle{
             attacker: %{
               army_size: 100_000,
               leadership: [2, 1],
               markers: 10,
               name: "BG",
               tactics: [2, 1]
             },
             defender: %{
               army_size: 90000,
               leadership: [3, 2],
               markers: 9,
               name: "N",
               tactics: [3, 2]
             },
             result: nil
           } = battle

    battle =
      battle
      |> run_and_assert_next_round(
        {9,
         %{
           markers_lost: 1,
           morale_modifier: 1,
           next_round_modifier: 1,
           tactics_modifier: -1
         }},
        {9,
         %{
           markers_lost: 0,
           morale_modifier: 0,
           next_round_modifier: 0,
           tactics_modifier: 0
         }}
      )
      |> run_and_assert_next_round(
        {9,
         %{
           markers_lost: 0,
           morale_modifier: 1,
           next_round_modifier: 1,
           tactics_modifier: -1
         }},
        {9,
         %{
           markers_lost: 0,
           morale_modifier: 1,
           next_round_modifier: 1,
           tactics_modifier: 1
         }},
        {-2, 1}
      )
      |> run_and_assert_next_round(
        {7,
         %{
           markers_lost: 2,
           morale_modifier: 1,
           next_round_modifier: 1,
           tactics_modifier: 1
         }},
        {9,
         %{
           markers_lost: 0,
           morale_modifier: 0,
           next_round_modifier: 0,
           tactics_modifier: -1
         }},
        {0, -2}
      )
      |> run_and_assert_next_round(
        {5,
         %{
           markers_lost: 2,
           morale_modifier: 1,
           next_round_modifier: 1,
           tactics_modifier: 1
         }},
        {9,
         %{
           markers_lost: 0,
           morale_modifier: 0,
           next_round_modifier: 0,
           tactics_modifier: -1
         }}
      )
      |> run_and_assert_next_round(
        {3,
         %{
           markers_lost: 2,
           morale_modifier: 0,
           next_round_modifier: 1,
           tactics_modifier: -3
         }},
        {7,
         %{
           markers_lost: 2,
           morale_modifier: 0,
           next_round_modifier: 0,
           tactics_modifier: -1
         }},
        {-4, 0}
      )
      |> run_and_assert_next_round(
        {-1,
         %{
           markers_lost: 4,
           morale_modifier: 1,
           next_round_modifier: 1,
           tactics_modifier: 1
         }},
        {7,
         %{
           markers_lost: 0,
           morale_modifier: 0,
           next_round_modifier: 0,
           tactics_modifier: -3
         }},
        {0, -2},
        "defender_won"
      )

    assert {:error, :battle_already_finished} = Regular.next_round(battle)
  end

  def run_and_assert_next_round(
        battle,
        {expected_attacker_markers, expected_attacker},
        {expected_defender_markers, expected_defender},
        {attacker_modifier, defender_modifier} \\ {0, 0},
        result \\ nil
      ) do
    battle =
      %Battle{rounds: [last_round | _]} =
      Regular.next_round(battle, attacker_modifier, defender_modifier)

    assert %Round{
             attacker: ^expected_attacker,
             defender: ^expected_defender
           } = last_round

    assert %Battle{
             attacker: %{
               army_size: 100_000,
               leadership: [2, 1],
               markers: ^expected_attacker_markers,
               name: "BG",
               tactics: [2, 1]
             },
             defender: %{
               army_size: 90_000,
               leadership: [3, 2],
               markers: ^expected_defender_markers,
               name: "N",
               tactics: [3, 2]
             },
             result: ^result
           } = battle
  end
end
