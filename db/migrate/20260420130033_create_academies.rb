class CreateAcademies < ActiveRecord::Migration[8.1]
  def change
    create_table :academies, id: :uuid do |t|
      t.string  :name,       null: false
      t.string  :slug,       null: false
      t.integer :plan,       null: false, default: 0   # enum: free/starter/pro/enterprise
      t.integer :status,     null: false, default: 0   # enum: trial/active/suspended/cancelled
      t.string  :sport_type, null: false, default: "soccer"
      t.string  :logo_url
      t.date    :trial_ends_on
      t.timestamps
    end

    add_index :academies, :slug,   unique: true
    add_index :academies, :status
    add_index :academies, :plan
  end
end
