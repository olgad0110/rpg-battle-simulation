defmodule RpgBattleSimulation.CommandedTest do
  use ExUnit.Case
  alias RpgBattleSimulation.Commanded.Projections.{Battle, Round}
  alias RpgBattleSimulation.Commanded

  test "flow of simulation" do
    assert :ok = Commanded.start(1)

    :timer.sleep(1000)

    assert %Battle{
             attacker: %{
               "army_size" => 100_000,
               "leadership" => [2, 1],
               "markers" => 10,
               "name" => "BG",
               "tactics" => [2, 1]
             },
             defender: %{
               "army_size" => 90000,
               "leadership" => [3, 2],
               "markers" => 9,
               "name" => "N",
               "tactics" => [3, 2]
             },
             id: 1,
             result: nil
           } = Commanded.get_battle(1)

    run_and_assert_next_round(
      1,
      {9,
       %{
         "markers_lost" => 1,
         "morale_modifier" => 1,
         "next_round_modifier" => 1,
         "tactics_modifier" => -1
       }},
      {9,
       %{
         "markers_lost" => 0,
         "morale_modifier" => 0,
         "next_round_modifier" => 0,
         "tactics_modifier" => 0
       }}
    )

    run_and_assert_next_round(
      2,
      {9,
       %{
         "markers_lost" => 0,
         "morale_modifier" => 1,
         "next_round_modifier" => 1,
         "tactics_modifier" => -1
       }},
      {9,
       %{
         "markers_lost" => 0,
         "morale_modifier" => 1,
         "next_round_modifier" => 1,
         "tactics_modifier" => 1
       }},
      {-2, 1}
    )

    run_and_assert_next_round(
      3,
      {7,
       %{
         "markers_lost" => 2,
         "morale_modifier" => 1,
         "next_round_modifier" => 1,
         "tactics_modifier" => 1
       }},
      {9,
       %{
         "markers_lost" => 0,
         "morale_modifier" => 0,
         "next_round_modifier" => 0,
         "tactics_modifier" => -1
       }},
      {0, -2}
    )

    run_and_assert_next_round(
      4,
      {5,
       %{
         "markers_lost" => 2,
         "morale_modifier" => 1,
         "next_round_modifier" => 1,
         "tactics_modifier" => 1
       }},
      {9,
       %{
         "markers_lost" => 0,
         "morale_modifier" => 0,
         "next_round_modifier" => 0,
         "tactics_modifier" => -1
       }}
    )

    run_and_assert_next_round(
      5,
      {3,
       %{
         "markers_lost" => 2,
         "morale_modifier" => 0,
         "next_round_modifier" => 1,
         "tactics_modifier" => -3
       }},
      {7,
       %{
         "markers_lost" => 2,
         "morale_modifier" => 0,
         "next_round_modifier" => 0,
         "tactics_modifier" => -1
       }},
      {-4, 0}
    )

    run_and_assert_next_round(
      6,
      {-1,
       %{
         "markers_lost" => 4,
         "morale_modifier" => 1,
         "next_round_modifier" => 1,
         "tactics_modifier" => 1
       }},
      {7,
       %{
         "markers_lost" => 0,
         "morale_modifier" => 0,
         "next_round_modifier" => 0,
         "tactics_modifier" => -3
       }},
      {0, -2},
      "defender_won"
    )

    assert {:error, :battle_already_finished} = Commanded.next_round(1)
  end

  def run_and_assert_next_round(
        round_number,
        {expected_attacker_markers, expected_attacker},
        {expected_defender_markers, expected_defender},
        {attacker_modifier, defender_modifier} \\ {0, 0},
        result \\ nil
      ) do
    assert :ok = Commanded.next_round(1, attacker_modifier, defender_modifier)

    :timer.sleep(1000)

    assert %Round{
             uuid: _,
             battle_id: 1,
             round: ^round_number,
             attacker: ^expected_attacker,
             defender: ^expected_defender
           } = Commanded.get_battle_last_round(1)

    next_round_number = round_number + 1

    assert %Battle{
             attacker: %{
               "army_size" => 100_000,
               "leadership" => [2, 1],
               "markers" => ^expected_attacker_markers,
               "name" => "BG",
               "tactics" => [2, 1]
             },
             defender: %{
               "army_size" => 90_000,
               "leadership" => [3, 2],
               "markers" => ^expected_defender_markers,
               "name" => "N",
               "tactics" => [3, 2]
             },
             id: 1,
             result: ^result,
             next_round_number: ^next_round_number
           } = Commanded.get_battle(1)
  end
end
