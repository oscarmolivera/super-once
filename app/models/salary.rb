class Salary < ApplicationRecord
  acts_as_tenant(:academy)

  belongs_to :academy
  belongs_to :employee

  # ── Enums ──────────────────────────────────────────────────────
  enum :status, { pending: 0, paid: 1 }, prefix: true

  # ── Validations ────────────────────────────────────────────────
  validates :amount, presence: true,
                     numericality: { greater_than_or_equal_to: 0 }
  validates :month,  presence: true,
                     inclusion: { in: 1..12 }
  validates :year,   presence: true,
                     numericality: { only_integer: true, greater_than: 2000 }
  validates :employee_id, uniqueness: {
    scope: [:academy_id, :month, :year],
    message: "already has a salary for this period"
  }

  # ── Scopes ─────────────────────────────────────────────────────
  scope :for_period,  ->(month, year) { where(month: month, year: year) }
  scope :pending,     -> { where(status: :pending) }
  scope :paid,        -> { where(status: :paid) }
  scope :this_month,  -> { for_period(Date.current.month, Date.current.year) }

  # ── Callbacks ──────────────────────────────────────────────────
  before_validation :set_amount_from_employee, on: :create

  # ── Instance helpers ───────────────────────────────────────────
  def period_label
    Date.new(year, month).strftime("%B %Y")
  end

  def mark_paid!
    update!(status: :paid, paid_on: Date.current)
  end

  private

  def set_amount_from_employee
    self.amount ||= employee&.base_salary || 0
  end
end
