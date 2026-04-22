class CreatePlayerPayments < ActiveRecord::Migration[8.1]
  def change
    create_table :player_payments, id: :uuid do |t|
      t.references :academy, null: false, foreign_key: true, type: :uuid
      # player_id added in Phase 4 when Player model exists.
      # For now we store player name as a string so Enterprise works standalone.
      t.string   :player_name,  null: false
      t.decimal  :amount,       null: false, precision: 10, scale: 2
      t.date     :due_on,       null: false
      t.date     :paid_on
      t.integer  :month,        null: false   # billing month 1-12
      t.integer  :year,         null: false
      t.integer  :status,       null: false, default: 0  # enum: pending/paid/overdue/waived
      t.string   :notes

      t.timestamps
    end

    add_index :player_payments, [:academy_id, :status]
    add_index :player_payments, [:academy_id, :due_on]
    add_index :player_payments, [:academy_id, :year, :month]
  end
end
