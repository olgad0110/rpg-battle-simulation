defmodule RpgBattleSimulation do
  defp attacker_data do
    %{name: "BG", tactics: [2, 1], leadership: [2, 1], army_size: 100_000}
  end

  defp defender_data do
    %{name: "N", tactics: [3, 2], leadership: [3, 2], army_size: 90_000}
  end
end
