class Announcement < ApplicationRecord
  acts_as_tenant(:academy)

  belongs_to :academy
  belongs_to :category, optional: true

  validates :title, presence: true
end
