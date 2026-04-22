class PracticeSession < ApplicationRecord
  acts_as_tenant(:academy)

  belongs_to :academy
  belongs_to :category

  has_many :attendance_records, dependent: :destroy

  validates :starts_at, presence: true
end
