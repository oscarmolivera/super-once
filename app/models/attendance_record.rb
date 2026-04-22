class AttendanceRecord < ApplicationRecord
  acts_as_tenant(:academy)

  belongs_to :academy
  belongs_to :practice_session
  belongs_to :player

  enum :status, { present: 0, absent: 1, late: 2 }, prefix: true

  validates :player_id, uniqueness: { scope: [:academy_id, :practice_session_id] }
end
