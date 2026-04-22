class CreateAttendanceRecords < ActiveRecord::Migration[8.1]
  def change
    create_table :attendance_records, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :academy, type: :uuid, null: false, foreign_key: true
      t.references :practice_session, type: :uuid, null: false, foreign_key: true
      t.references :player, type: :uuid, null: false, foreign_key: true
      t.integer :status
      t.text :notes

      t.timestamps
    end

    add_index :attendance_records, [:academy_id, :practice_session_id, :player_id], unique: true, name: "idx_attendance_records_unique"
  end
end
