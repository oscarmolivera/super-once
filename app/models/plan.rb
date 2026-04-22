# SaaS Plan definition
# Defines feature tiers: Free, Starter, Pro
class Plan < ApplicationRecord
  has_many :subscriptions, dependent: :destroy

  # ── Enums ───────────────────────────────────────────────────
  enum :tier, { free: 'free', starter: 'starter', pro: 'pro' }

  # ── Validations ─────────────────────────────────────────────
  validates :tier, presence: true, uniqueness: true
  validates :name, presence: true
  validates :price_cents, numericality: { greater_than_or_equal_to: 0 }
  validates :monthly_cost_cents, numericality: { greater_than_or_equal_to: 0 }
  validates :trial_days, numericality: { only_integer: true, greater_than: 0 }

  # ── Scopes ──────────────────────────────────────────────────
  scope :visible, -> { where(visible: true) }

  # ── Instance Methods ────────────────────────────────────────
  def price_amount
    price_cents / 100.0
  end

  def display_name
    "#{name} - $#{price_amount}/month"
  end

  def features_array
    features.to_s.split(',').map(&:strip)
  end
end
