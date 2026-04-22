class CreateMatches < ActiveRecord::Migration[8.1]
  def change
    create_table :matches, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :academy, type: :uuid, null: false, foreign_key: true
      t.references :tournament, type: :uuid, null: false, foreign_key: true
      t.references :cup_team, type: :uuid, null: false, foreign_key: true
      t.string :opponent_name
      t.datetime :starts_at
      t.string :venue
      t.boolean :home, default: true, null: false
      t.integer :status, default: 0, null: false
      t.integer :home_score
      t.integer :away_score
      t.text :notes

      t.timestamps
    end

    add_index :matches, [:academy_id, :tournament_id, :starts_at]
  end
end
