class Tournament < ApplicationRecord
  acts_as_tenant(:academy)

  belongs_to :academy
  belongs_to :cup

  has_many :cup_teams, dependent: :destroy
  has_many :matches, dependent: :destroy

  validates :year, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 2000 }

  def display_name
    "#{cup.name} — #{year}"
  end
end
