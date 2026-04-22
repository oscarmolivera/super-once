class Player < ApplicationRecord
  acts_as_tenant(:academy)

  belongs_to :academy

  has_many :category_enrollments, dependent: :destroy
  has_many :categories, through: :category_enrollments

  has_many :attendance_records, dependent: :destroy

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :birth_date, presence: true
end
