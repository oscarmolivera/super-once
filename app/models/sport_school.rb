class SportSchool < ApplicationRecord
  acts_as_tenant(:academy)

  belongs_to :academy

  has_many :categories, dependent: :destroy

  validates :name, presence: true
  validates :sport_type, presence: true
  validates :sport_type, uniqueness: { scope: :academy_id }
end
