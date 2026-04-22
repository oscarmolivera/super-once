class CreateCups < ActiveRecord::Migration[8.1]
  def change
    create_table :cups, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :academy, type: :uuid, null: false, foreign_key: true
      t.string :name
      t.string :organizer
      t.string :sport_type
      t.boolean :recurring, default: true, null: false

      t.timestamps
    end

    add_index :cups, [:academy_id, :sport_type, :name], unique: true
  end
end
