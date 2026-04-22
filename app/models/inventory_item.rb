class InventoryItem < ApplicationRecord
  acts_as_tenant(:academy)

  belongs_to :academy

  # ── Enums ──────────────────────────────────────────────────────
  enum :condition, {
    new_item:  0,
    good:      1,
    fair:      2,
    poor:      3
  }, prefix: true

  enum :category, {
    equipment: 0,
    apparel:   1,
    medical:   2,
    office:    3,
    other:     4
  }, prefix: true

  # ── Validations ────────────────────────────────────────────────
  validates :name,      presence: true
  validates :quantity,  presence: true,
                        numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :condition, presence: true

  # ── Scopes ─────────────────────────────────────────────────────
  scope :in_stock,  -> { where("quantity > 0") }
  scope :low_stock, -> { where("quantity > 0 AND quantity <= 3") }
  scope :ordered,   -> { order(:category, :name) }

  # ── Instance helpers ───────────────────────────────────────────
  def total_value
    return nil unless unit_value
    (quantity * unit_value).round(2)
  end

  def display_condition
    condition.to_s.humanize
  end
end
