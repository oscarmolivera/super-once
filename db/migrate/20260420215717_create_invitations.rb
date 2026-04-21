class CreateInvitations < ActiveRecord::Migration[8.1]
  def change
    create_table :invitations, id: :uuid do |t|
      t.references :academy,    null: false, foreign_key: true, type: :uuid
      t.references :invited_by, null: false, foreign_key: { to_table: :users }
      t.string     :email,      null: false
      t.string     :token,      null: false
      t.integer    :role,       null: false, default: 0   # mirrors Membership roles
      t.datetime   :accepted_at
      t.datetime   :expires_at, null: false
      t.timestamps
    end

    add_index :invitations, :token,                    unique: true
    add_index :invitations, %i[academy_id email],      unique: true
    add_index :invitations, :expires_at
  end
end
