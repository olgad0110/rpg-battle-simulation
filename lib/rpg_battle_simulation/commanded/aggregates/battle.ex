defmodule RpgBattleSimulation.Commanded.Aggregates.Battle do
  alias RpgBattleSimulation.Commanded.{
    Commands.StartBattle,
    Commands.EndRound,
    Commands.EndBattle,
    Events.BattleStarted,
    Events.RoundEnded,
    Events.BattleEnded
  }

  alias RpgBattleSimulation.RpgRules

  @type stats :: %{
          name: String.t(),
          tactics: list(integer()),
          leadership: list(integer()),
          army_size: integer(),
          markers: integer()
        }

  @type t :: %__MODULE__{
          id: integer(),
          attacker: stats(),
          defender: stats(),
          result: String.t(),
          next_round_number: integer()
        }
  @derive Jason.Encoder
  defstruct [:id, :attacker, :defender, :result, :next_round_number]

  def execute(%__MODULE__{id: nil}, %StartBattle{id: id, attacker: attacker, defender: defender}) do
    {attacker_markers, defender_markers} =
      RpgRules.calculate_battle_markers(attacker[:army_size], defender[:army_size])

    %BattleStarted{
      id: id,
      next_round_number: 1,
      attacker: Map.put(attacker, :markers, attacker_markers),
      defender: Map.put(defender, :markers, defender_markers)
    }
  end

  def execute(%__MODULE__{}, %StartBattle{}), do: {:error, :battle_already_started}

  def execute(
        %__MODULE__{next_round_number: next_round_number, attacker: attacker, defender: defender},
        %EndRound{
          id: id,
          attacker: round_attacker,
          defender: round_defender
        }
      ) do
    %RoundEnded{
      id: id,
      next_round_number: next_round_number + 1,
      attacker: Map.put(attacker, :markers, attacker[:markers] - round_attacker[:markers_lost]),
      defender: Map.put(defender, :markers, defender[:markers] - round_defender[:markers_lost])
    }
  end

  def execute(%__MODULE__{attacker: attacker, defender: defender}, %EndBattle{id: id}) do
    %BattleEnded{
      id: id,
      result: RpgRules.compute_battle_result(attacker[:markers], defender[:markers])
    }
  end

  def apply(%__MODULE__{} = battle, %BattleStarted{
        id: id,
        attacker: attacker,
        defender: defender,
        next_round_number: next_round_number
      }) do
    IO.puts("Event.BattleStarted")

    %__MODULE__{
      battle
      | id: id,
        attacker: attacker,
        defender: defender,
        next_round_number: next_round_number
    }
  end

  def apply(%__MODULE__{} = battle, %RoundEnded{
        attacker: attacker,
        defender: defender,
        next_round_number: next_round_number
      }) do
    IO.puts("Event.RoundEnded")

    %__MODULE__{
      battle
      | attacker: attacker,
        defender: defender,
        next_round_number: next_round_number
    }
  end

  def apply(%__MODULE__{} = battle, %BattleEnded{result: result}) do
    IO.puts("Event.BattleEnded")

    %__MODULE__{battle | result: result}
  end
end
