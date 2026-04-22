class CreateSportSchools < ActiveRecord::Migration[8.1]
  def change
    create_table :sport_schools, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :academy, type: :uuid, null: false, foreign_key: true
      t.string :name
      t.string :sport_type

      t.timestamps
    end
  end
end
