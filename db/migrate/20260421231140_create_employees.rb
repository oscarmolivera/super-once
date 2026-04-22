class CreateEmployees < ActiveRecord::Migration[8.1]
  def change
    create_table :employees, id: :uuid do |t|
      t.references :academy, null: false, foreign_key: true, type: :uuid

      t.string  :full_name,       null: false
      t.string  :email
      t.string  :phone
      t.integer :employee_type,   null: false, default: 0  # enum: coach/assistant_coach/staff
      t.integer :status,          null: false, default: 0  # enum: active/inactive
      t.date    :hire_date
      t.date    :birth_date
      t.string  :document_number                           # ID / passport
      t.decimal :base_salary,     precision: 10, scale: 2, default: 0
      t.string  :notes

      t.timestamps
    end

    add_index :employees, [:academy_id, :employee_type]
    add_index :employees, [:academy_id, :status]
  end
end
