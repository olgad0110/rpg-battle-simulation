defmodule RpgBattleSimulation.RegularTest do
  use ExUnit.Case
  alias RpgBattleSimulation.Regular.{Battle, Round}
  alias RpgBattleSimulation.Regular

  test "flow of simulation" do
    battle =
      Regular.start(%{name: "BG", tactics: [2, 1], leadership: [2, 1], army_size: 100_000}, %{
        name: "N",
        tactics: [3, 2],
        leadership: [3, 2],
        army_size: 90_000
      })

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
           next_round_modifier: 2,
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
           next_round_modifier: 3,
           tactics_modifier: 2
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
           next_round_modifier: 4,
           tactics_modifier: 3
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
           next_round_modifier: 0,
           tactics_modifier: -4
         }},
        {6,
         %{
           markers_lost: 3,
           morale_modifier: 0,
           next_round_modifier: 1,
           tactics_modifier: -1
         }},
        {-8, 0}
      )
      |> run_and_assert_next_round(
        {0,
         %{
           markers_lost: 3,
           morale_modifier: 1,
           next_round_modifier: 1,
           tactics_modifier: 0
         }},
        {6,
         %{
           markers_lost: 0,
           morale_modifier: 0,
           next_round_modifier: 0,
           tactics_modifier: -2
         }},
        {0, -2},
        "defender_won"
      )

    assert {:error, :battle_already_finished} = Regular.next_round(battle)
  end

  test "flow of simulation with heroes" do
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
        {7,
         %{
           markers_lost: 2,
           morale_modifier: 0,
           next_round_modifier: 2,
           tactics_modifier: -3
         }},
        {7,
         %{
           markers_lost: 2,
           morale_modifier: 0,
           next_round_modifier: 0,
           tactics_modifier: -1
         }},
        {-2, 1}
      )
      |> run_and_assert_next_round(
        {2,
         %{
           markers_lost: 5,
           morale_modifier: 1,
           next_round_modifier: 3,
           tactics_modifier: 2
         }},
        {7,
         %{
           markers_lost: 0,
           morale_modifier: 0,
           next_round_modifier: 0,
           tactics_modifier: -4
         }},
        {0, -2}
      )
      |> run_and_assert_next_round(
        {-2,
         %{
           markers_lost: 4,
           morale_modifier: 0,
           next_round_modifier: 4,
           tactics_modifier: -3
         }},
        {5,
         %{
           markers_lost: 2,
           morale_modifier: 0,
           next_round_modifier: 0,
           tactics_modifier: -3
         }},
        {-4, 0},
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
