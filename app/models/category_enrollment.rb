class CategoryEnrollment < ApplicationRecord
  acts_as_tenant(:academy)

  belongs_to :academy
  belongs_to :category
  belongs_to :player

  enum :status, { active: 0, ended: 1 }, prefix: true

  validates :category_id, uniqueness: { scope: [:academy_id, :player_id] }
end
