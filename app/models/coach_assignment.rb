class CoachAssignment < ApplicationRecord
  acts_as_tenant(:academy)

  belongs_to :academy
  belongs_to :category
  belongs_to :employee

  enum :role, { head: 0, assistant: 1 }, prefix: true

  validates :category_id, uniqueness: { scope: [:academy_id, :employee_id] }
end
