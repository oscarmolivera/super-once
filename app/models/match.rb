class Match < ApplicationRecord
  acts_as_tenant(:academy)

  belongs_to :academy
  belongs_to :tournament
  belongs_to :cup_team

  enum :status, { scheduled: 0, played: 1, cancelled: 2 }, prefix: true

  validates :opponent_name, presence: true
  validates :starts_at, presence: true
  validates :home_score, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validates :away_score, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
end
