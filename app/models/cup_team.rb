class CupTeam < ApplicationRecord
  acts_as_tenant(:academy)

  belongs_to :academy
  belongs_to :tournament
  belongs_to :category

  has_many :team_players, dependent: :destroy
  has_many :players, through: :team_players

  has_many :matches, dependent: :restrict_with_error

  validates :name, presence: true
end
