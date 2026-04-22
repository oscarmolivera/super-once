class Cup < ApplicationRecord
  acts_as_tenant(:academy)

  belongs_to :academy

  has_many :tournaments, dependent: :destroy

  validates :name, presence: true
  validates :sport_type, presence: true
end
