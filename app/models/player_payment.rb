class PlayerPayment < ApplicationRecord
  acts_as_tenant(:academy)

  belongs_to :academy
  # Will gain `belongs_to :player` in Phase 4.
  # For now player_name is a plain string column.

  # ── Enums ──────────────────────────────────────────────────────
  enum :status, {
    pending:  0,
    paid:     1,
    overdue:  2,
    waived:   3
  }, prefix: true

  # ── Validations ────────────────────────────────────────────────
  validates :player_name, presence: true
  validates :amount,      presence: true,
                          numericality: { greater_than: 0 }
  validates :due_on,      presence: true
  validates :month,       presence: true, inclusion: { in: 1..12 }
  validates :year,        presence: true,
                          numericality: { only_integer: true, greater_than: 2000 }

  # ── Scopes ─────────────────────────────────────────────────────
  scope :pending,    -> { where(status: :pending) }
  scope :paid,       -> { where(status: :paid) }
  scope :overdue,    -> { where(status: :overdue) }
  scope :due_today,  -> { pending.where(due_on: ..Date.current) }
  scope :this_month, -> { where(month: Date.current.month, year: Date.current.year) }
  scope :recent,     -> { order(due_on: :desc) }

  # ── Callbacks ──────────────────────────────────────────────────
  before_save :auto_mark_overdue

  # ── Instance helpers ───────────────────────────────────────────
  def mark_paid!
    update!(status: :paid, paid_on: Date.current)
  end

  def period_label
    Date.new(year, month).strftime("%B %Y")
  end

  private

  def auto_mark_overdue
    if status_pending? && due_on.present? && due_on < Date.current
      self.status = :overdue
    end
  end
end
