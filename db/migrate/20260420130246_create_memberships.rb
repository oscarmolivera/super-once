class CreateMemberships < ActiveRecord::Migration[8.0]
  def change
    create_table :memberships, id: :uuid do |t|
      t.references :academy, null: false, foreign_key: true, type: :uuid
      t.references :user,    null: false, foreign_key: true
      t.integer    :role,    null: false, default: 0   # enum: member/admin/owner
      t.datetime   :invited_at
      t.datetime   :accepted_at
      t.timestamps
    end

    # One membership per user per academy
    add_index :memberships, %i[academy_id user_id], unique: true
    add_index :memberships, :role
  end
end
