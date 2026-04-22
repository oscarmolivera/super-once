class CreateCategoryEnrollments < ActiveRecord::Migration[8.1]
  def change
    create_table :category_enrollments, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :academy, type: :uuid, null: false, foreign_key: true
      t.references :category, type: :uuid, null: false, foreign_key: true
      t.references :player, type: :uuid, null: false, foreign_key: true
      t.date :starts_on
      t.date :ends_on
      t.integer :status

      t.timestamps
    end

    add_index :category_enrollments, [:academy_id, :category_id, :player_id], unique: true, name: "idx_category_enrollments_unique"
  end
end
