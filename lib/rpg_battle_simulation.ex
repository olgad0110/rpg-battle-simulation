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

  def test_group_1 do
    defender = %{
      name: "group 1",
      tactics: [3, 1],
      leadership: [2, 1],
      army_size: 400,
      heroes: [[4, 4], [4, 3], [4, 4]]
    }

    Logic.start(@nilfgaard_small_army, defender)
    |> do_next_round_until_finished()
  end

  def test_group_2 do
    defender = %{
      name: "group 1",
      tactics: [2, 1],
      leadership: [3, 2],
      army_size: 400,
      heroes: [[4, 4], [4, 4], [3, 4], [3, 4]]
    }

    Logic.start(@nilfgaard_small_army, defender)
    |> do_next_round_until_finished()
  end

  defp do_next_round_until_finished(%{result: nil} = battle) do
    battle
    |> Logic.next_round()
    |> do_next_round_until_finished()
  end

  defp do_next_round_until_finished(battle), do: battle

  def simulate_probability(function, simulations \\ 1_000) do
    1..simulations
    |> Flow.from_enumerable()
    |> Flow.map(fn _ -> function.() end)
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
    |> format_data(simulations)
  end

  defp format_data([results], simulations) do
    results
    |> Enum.map(fn {result, data} ->
      total_value = data |> Enum.map(fn {_, k} -> k end) |> Enum.sum()
      total_percentage = to_percentage(total_value, simulations)
      rounds_percentage = data |> Enum.map(fn {v, k} -> {v, to_percentage(k, total_value)} end)

      {result, %{chance: total_percentage, rounds: rounds_percentage}}
    end)
  end

  defp to_percentage(value, total) do
    result = (value * 1.0 / total * 100) |> Float.round(2)
    "#{result}%"
  end
end
