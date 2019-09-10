defmodule RpgBattleSimulation.Repo.Migrations.AddProjections do
  use Ecto.Migration

  def change do
  	create table(:projection_versions, primary_key: false) do
  		add :projection_name, :text, primary_key: true
  		add :last_seen_event_number, :bigint

  		timestamps()
  	end

  	create table(:battle_projections) do
  		add :attacker, :map
			add :defender, :map
			add :result, :string		
      add :next_round_number, :integer
  	end

    create table(:round_projections) do
      add :uuid, :string
      add :battle_id, :integer
      add :round, :integer
      add :attacker, :map
      add :defender, :map
    end
  end
end
