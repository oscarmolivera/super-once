class CreateCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :categories, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :sport_school, type: :uuid, null: false, foreign_key: false
      t.string :name
      t.integer :min_age
      t.integer :max_age

      t.timestamps
    end
  end
end
