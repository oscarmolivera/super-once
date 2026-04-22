class CreateTeamPlayers < ActiveRecord::Migration[8.1]
  def change
    create_table :team_players, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :academy, type: :uuid, null: false, foreign_key: true
      t.references :cup_team, type: :uuid, null: false, foreign_key: true
      t.references :player, type: :uuid, null: false, foreign_key: true
      t.integer :jersey_number
      t.string :position

      t.timestamps
    end

    add_index :team_players, [:academy_id, :cup_team_id, :player_id], unique: true
    add_index :team_players, [:academy_id, :cup_team_id, :jersey_number], unique: true, where: "jersey_number IS NOT NULL"
  end
end
