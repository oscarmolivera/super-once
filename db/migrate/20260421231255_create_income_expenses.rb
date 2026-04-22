class CreateIncomeExpenses < ActiveRecord::Migration[8.1]
  def change
    create_table :income_expenses, id: :uuid do |t|
      t.references :academy, null: false, foreign_key: true, type: :uuid

      t.integer  :kind,        null: false, default: 0  # enum: income/expense
      t.decimal  :amount,      null: false, precision: 10, scale: 2
      t.string   :description, null: false
      t.integer  :category,    null: false, default: 0  # enum: rent/utilities/equipment/sponsorship/other…
      t.date     :recorded_on, null: false
      t.string   :reference                             # invoice number, receipt ref, etc.

      t.timestamps
    end

    add_index :income_expenses, [:academy_id, :kind]
    add_index :income_expenses, [:academy_id, :recorded_on]
    add_index :income_expenses, [:academy_id, :category]
  end
end
