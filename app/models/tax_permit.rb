class TaxPermit < ApplicationRecord
  acts_as_tenant(:academy)

  belongs_to :academy

  # ── Enums ──────────────────────────────────────────────────────
  enum :document_type, {
    tax:       0,
    permit:    1,
    insurance: 2,
    license:   3,
    other:     4
  }, prefix: true

  enum :status, {
    active:           0,
    expired:          1,
    pending_renewal:  2
  }, prefix: true

  # ── Validations ────────────────────────────────────────────────
  validates :name,          presence: true
  validates :document_type, presence: true

  # ── Scopes ─────────────────────────────────────────────────────
  scope :active,            -> { where(status: :active) }
  scope :expiring_soon,     -> { active.where(expires_on: Date.current..30.days.from_now) }
  scope :expired,           -> { where(status: :expired).or(where("expires_on < ?", Date.current)) }
  scope :ordered,           -> { order(:expires_on) }

  # ── Callbacks ──────────────────────────────────────────────────
  before_save :auto_update_status

  # ── Instance helpers ───────────────────────────────────────────
  def days_until_expiry
    return nil unless expires_on
    (expires_on - Date.current).to_i
  end

  def expiring_soon?
    expires_on.present? && expires_on <= 30.days.from_now && expires_on >= Date.current
  end

  private

  def auto_update_status
    return unless expires_on.present?
    if expires_on < Date.current && !status_pending_renewal?
      self.status = :expired
    end
  end
end
