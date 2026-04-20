class AddSuperonceColumnsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :superadmin, :boolean, null: false, default: false

    # Display name (optional — email is the login identifier)
    add_column :users, :full_name, :string

    add_index :users, :superadmin, where: "superadmin = true"
  end
end
