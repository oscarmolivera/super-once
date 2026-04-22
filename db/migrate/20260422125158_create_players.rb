class CreatePlayers < ActiveRecord::Migration[8.1]
  def change
    create_table :players, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :academy, type: :uuid, null: false, foreign_key: true
      t.string :first_name
      t.string :last_name
      t.date :birth_date
      t.string :guardian_name
      t.string :guardian_phone
      t.string :guardian_email
      t.string :photo_url

      t.timestamps
    end
  end
end
