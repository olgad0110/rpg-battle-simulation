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
      fn battle, acc -> Map.update(acc, battle.result, 1, &(&1 + 1)) end
    )
    |> Flow.departition(&Map.new/0, &Map.merge(&1, &2, fn _, v1, v2 -> v1 + v2 end), & &1)
    |> Enum.to_list()
  end
end
