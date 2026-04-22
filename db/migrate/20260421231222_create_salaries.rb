class CreateSalaries < ActiveRecord::Migration[8.1]
  def change
    create_table :salaries, id: :uuid do |t|
      t.references :academy,  null: false, foreign_key: true, type: :uuid
      t.references :employee, null: false, foreign_key: true, type: :uuid

      t.decimal :amount,      null: false, precision: 10, scale: 2
      t.integer :month,       null: false   # 1-12
      t.integer :year,        null: false
      t.integer :status,      null: false, default: 0  # enum: pending/paid
      t.date    :paid_on
      t.string  :notes

      t.timestamps
    end

    # One salary record per employee per month/year
    add_index :salaries, [:academy_id, :employee_id, :month, :year], unique: true, name: "idx_salaries_employee_period"
    add_index :salaries, [:academy_id, :year, :month]
    add_index :salaries, [:academy_id, :status]
  end
end
