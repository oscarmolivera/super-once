class CreateCoachAssignments < ActiveRecord::Migration[8.1]
  def change
    create_table :coach_assignments, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :academy, type: :uuid, null: false, foreign_key: true
      t.references :category, type: :uuid, null: false, foreign_key: true
      t.references :employee, type: :uuid, null: false, foreign_key: true
      t.integer :role

      t.timestamps
    end

    add_index :coach_assignments, [:academy_id, :category_id, :employee_id], unique: true, name: "idx_coach_assignments_unique"
  end
end
