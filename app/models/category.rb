class Category < ApplicationRecord
  acts_as_tenant(:academy)

  belongs_to :academy
  belongs_to :sport_school

  has_many :category_enrollments, dependent: :destroy
  has_many :players, through: :category_enrollments

  has_many :coach_assignments, dependent: :destroy
  has_many :coaches, through: :coach_assignments, source: :employee

  has_many :practice_sessions, dependent: :destroy
  has_many :training_plans, dependent: :destroy
  has_many :announcements, dependent: :nullify

  validates :name, presence: true
end
