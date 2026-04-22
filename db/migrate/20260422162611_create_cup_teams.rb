class CreateCupTeams < ActiveRecord::Migration[8.1]
  def change
    create_table :cup_teams, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :academy, type: :uuid, null: false, foreign_key: true
      t.references :tournament, type: :uuid, null: false, foreign_key: true
      t.references :category, type: :uuid, null: false, foreign_key: true
      t.string :name

      t.timestamps
    end

    add_index :cup_teams, [:academy_id, :tournament_id, :category_id], unique: true
  end
end
