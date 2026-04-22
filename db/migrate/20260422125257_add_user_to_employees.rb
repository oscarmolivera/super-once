class AddUserToEmployees < ActiveRecord::Migration[8.1]
  def change
    add_reference :employees, :user, null: true, foreign_key: true
    add_index :employees, [:academy_id, :user_id], unique: true, where: "user_id IS NOT NULL"
  end
end
