class CreateTournaments < ActiveRecord::Migration[8.1]
  def change
    create_table :tournaments, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :academy, type: :uuid, null: false, foreign_key: true
      t.references :cup, type: :uuid, null: false, foreign_key: true
      t.integer :year
      t.date :starts_on
      t.date :ends_on
      t.string :location

      t.timestamps
    end

    add_index :tournaments, [:academy_id, :cup_id, :year], unique: true
  end
end
