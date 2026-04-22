class CreatePracticeSessions < ActiveRecord::Migration[8.1]
  def change
    create_table :practice_sessions, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :academy, type: :uuid, null: false, foreign_key: true
      t.references :category, type: :uuid, null: false, foreign_key: true
      t.datetime :starts_at
      t.datetime :ends_at
      t.string :location
      t.text :notes

      t.timestamps
    end

    add_index :practice_sessions, [:academy_id, :category_id, :starts_at]
  end
end
