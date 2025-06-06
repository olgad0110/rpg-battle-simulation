defmodule RpgBattleSimulation.RpgRules do
  @successes [4, 5, 6]
  @base_modifier 4

  def roll_k6, do: :rand.uniform(6)
  def roll_k6(n), do: Enum.map(1..n, fn _ -> roll_k6() end)

  def roll_k6_successes(n, :test), do: round(n / 2)

  def roll_k6_successes(n, _) do
    roll_k6(n)
    |> Enum.filter(fn result -> result in @successes end)
    |> length()
  end

  def roll_k6_successes_with_destiny(n, :test), do: {1, round(n / 2)}

  def roll_k6_successes_with_destiny(n, _) do
    [destiny_dice | _] = dices = roll_k6(n)

    {destiny_dice,
     dices
     |> Enum.filter(fn result -> result in @successes end)
     |> length()}
  end

  @spec calculate_battle_markers(attacker_army_size :: integer(), defender_army_size :: integer()) ::
          {attacker_markers :: integer(), defender_markers :: integer()}
  def calculate_battle_markers(army_size, army_size), do: {10, 10}

  def calculate_battle_markers(attacker_army_size, defender_army_size)
      when attacker_army_size > defender_army_size,
      do: {10, round(defender_army_size / (attacker_army_size / 10))}

  def calculate_battle_markers(attacker_army_size, defender_army_size)
      when attacker_army_size < defender_army_size,
      do: {round(attacker_army_size / (defender_army_size / 10)), 10}

  @spec calculate_round_modifiers(
          {attacker_size :: integer(), attacker_modifier :: integer()},
          {defender_size :: integer(), defender_modifier :: integer}
        ) :: {attacker_total_modifier :: integer(), defender_total_modifier :: integer()}
  def calculate_round_modifiers(
        {size, attacker_modifier},
        {size, defender_modifier}
      ),
      do: {attacker_modifier, defender_modifier}

  def calculate_round_modifiers(
        {attacker_size, attacker_modifier},
        {defender_size, defender_modifier}
      )
      when attacker_size > defender_size,
      do: {attacker_modifier - 1, defender_modifier}

  def calculate_round_modifiers(
        {attacker_size, attacker_modifier},
        {defender_size, defender_modifier}
      )
      when attacker_size < defender_size,
      do: {attacker_modifier, defender_modifier - 1}

  def calculate_hero_modifiers(nil, _modifier), do: 0
  def calculate_hero_modifiers([], _modifier), do: 0

  def calculate_hero_modifiers(heroes, modifier) do
    heroes
    |> Enum.map(fn [dices, skill_value] ->
      difficulty_level = @base_modifier + modifier - skill_value

      {difficulty_level, roll_k6_successes_with_destiny(dices, Mix.env())}
      |> case do
        {dl, {6, successes}} when dl - 2 <= successes -> -1
        {dl, {_, successes}} when dl > successes -> 0
        {_dl, {_, _successes}} -> -1
      end
    end)
    |> Enum.sum()
  end

  @spec test_tactics(list(integer()), modifier :: integer()) ::
          {markers_lost :: integer(), morale_modifier :: integer()}
  def test_tactics([dices, skill_value], modifier) do
    difficulty_level = @base_modifier + modifier - skill_value

    {difficulty_level, roll_k6_successes_with_destiny(dices, Mix.env())}
    |> case do
      {dl, {6, successes}} when dl - 2 <= successes -> {1, 0}
      {dl, {_, successes}} when dl > successes -> {0, 1}
      {dl, {_, successes}} -> {successes - dl + 1, 0}
    end
  end

  @spec test_morale(
          tactics_skill :: list(integer()),
          modifier :: integer(),
          markers_lost :: integer(),
          opponent_markers_lost :: integer(),
          previous_round_morale_outcome :: integer()
        ) :: next_round_modifier :: integer()
  def test_morale(
        tactics_skill,
        modifier,
        markers_lost,
        opponent_markers_lost,
        previous_round_morale_outcome \\ 0
      )

  def test_morale(
        [dices, skill_value],
        modifier,
        markers_lost,
        opponent_markers_lost,
        previous_round_morale_outcome
      )
      when markers_lost >= opponent_markers_lost do
    difficulty_level =
      @base_modifier + modifier + (markers_lost - opponent_markers_lost) - skill_value

    {difficulty_level, roll_k6_successes_with_destiny(dices, Mix.env())}
    |> case do
      {dl, {6, successes}} when dl - 2 <= successes -> 0
      {dl, {_, successes}} when dl > successes -> previous_round_morale_outcome + 1
      {_dl, _successes} -> 0
    end
  end

  def test_morale(
        [_dices, _skill_value],
        _modifier,
        _markers_lost,
        _opponent_markers_lost,
        _previous_round_morale_outcome
      ),
      do: 0

  def compute_battle_result(markers, markers), do: "draw"

  def compute_battle_result(attacker_markers, defender_markers)
      when attacker_markers > defender_markers,
      do: "attacker_won"

  def compute_battle_result(attacker_markers, defender_markers)
      when attacker_markers < defender_markers,
      do: "defender_won"
end
