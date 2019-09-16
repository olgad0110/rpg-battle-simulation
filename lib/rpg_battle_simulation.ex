defmodule RpgBattleSimulation do
  alias RpgBattleSimulation.Regular, as: Logic

  @nilfgaard_small_army %{
    name: "Nilfgaard group",
    tactics: [2, 1],
    leadership: [2, 1],
    army_size: 500,
    heroes: [
      [4, 4],
      [4, 4],
      [4, 4]
    ]
  }

  @group_1 %{
    name: "group 1",
    tactics: [3, 1],
    leadership: [2, 1],
    army_size: 400,
    heroes: [[4, 4], [4, 3], [4, 4]]
  }

  @group_2 %{
    name: "group 1",
    tactics: [2, 1],
    leadership: [3, 2],
    army_size: 400,
    heroes: [[4, 4], [4, 4], [3, 4], [3, 4]]
  }

  def nilfgaard_small_army, do: @nilfgaard_small_army
  def group_1, do: @group_1
  def group_2, do: @group_2

  def test_run(defender, attacker \\ @nilfgaard_small_army) do
    Logic.start(attacker, defender)
    |> do_next_round_until_finished()
  end

  defp do_next_round_until_finished(%{result: nil} = battle) do
    battle
    |> Logic.next_round()
    |> do_next_round_until_finished()
  end

  defp do_next_round_until_finished(battle), do: battle

  def simulate_probability(defender, attacker \\ @nilfgaard_small_army, simulations \\ 1_000) do
    1..simulations
    |> Flow.from_enumerable()
    |> Flow.map(fn _ -> test_run(defender, attacker) end)
    |> Flow.partition()
    |> Flow.reduce(
      fn -> %{} end,
      fn battle, acc ->
        rounds = battle.rounds |> length() |> Integer.to_string()

        Map.update(
          acc,
          battle.result,
          %{} |> Map.put(rounds, 1),
          fn map -> Map.update(map, rounds, 1, &(&1 + 1)) end
        )
      end
    )
    |> Flow.departition(
      &Map.new/0,
      &Map.merge(&1, &2, fn _, v1, v2 -> Map.merge(v1, v2, fn _, v1, v2 -> v1 + v2 end) end),
      & &1
    )
    |> Enum.to_list()
    |> List.first()
    |> format_data(simulations)
  end

  defp format_data(results, simulations) do
    results
    |> Enum.map(fn {result, data} ->
      total_value = data |> Enum.map(fn {_, k} -> k end) |> Enum.sum()
      total_percentage = to_percentage(total_value, simulations)
      rounds_percentage = data |> Enum.map(fn {v, k} -> {v, to_percentage(k, total_value)} end)

      {result, %{chance: total_percentage, rounds: rounds_percentage}}
    end)
    |> Map.new()
  end

  defp to_percentage(value, total) do
    (value * 1.0 / total * 100) |> Float.round(2)
  end

  def find_best_values_for_probability(
        defender,
        attacker_won_desired_probability,
        simulations \\ 100
      ) do
    1..simulations
    |> Flow.from_enumerable()
    |> Flow.map(fn _ ->
      attacker_input_data =
        @nilfgaard_small_army
        |> Map.put(:tactics, random_skills())
        |> Map.put(:leadership, random_skills())
        |> Map.put(:heroes, [random_skills(), random_skills(), random_skills()])

      {attacker_input_data, simulate_probability(defender, attacker_input_data)}
    end)
    |> Flow.partition()
    |> Flow.reduce(
      fn -> %{} end,
      fn {input_data, simulation_result}, acc ->
        case simulation_result["attacker_won"][:chance] do
          percentage
          when percentage <= attacker_won_desired_probability + 5 and
                 percentage >= attacker_won_desired_probability - 5 ->
            Map.put(acc, percentage, input_data)

          _ ->
            acc
        end
      end
    )
    |> Flow.departition(&Map.new/0, &Map.merge/2, & &1)
    |> Enum.to_list()
    |> List.first()
  end

  defp random_skills() do
    dices = :rand.uniform(4)
    skill = :rand.uniform(5) - 1

    [dices, skill]
  end
end
