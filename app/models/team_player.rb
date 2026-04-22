class TeamPlayer < ApplicationRecord
  acts_as_tenant(:academy)

  belongs_to :academy
  belongs_to :cup_team
  belongs_to :player

  validates :player_id, uniqueness: { scope: [:academy_id, :cup_team_id] }
  validates :jersey_number, numericality: { only_integer: true, greater_than: 0, less_than: 100 }, allow_nil: true
end
