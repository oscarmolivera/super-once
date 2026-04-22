class TrainingPlan < ApplicationRecord
  acts_as_tenant(:academy)

  belongs_to :academy
  belongs_to :category

  validates :title, presence: true
end
