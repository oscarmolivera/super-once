class Employee < ApplicationRecord
  acts_as_tenant(:academy)

  belongs_to :academy
  has_many   :salaries, dependent: :destroy

  # ── Enums ──────────────────────────────────────────────────────
  enum :employee_type, {
    coach:           0,
    assistant_coach: 1,
    staff:           2
  }, prefix: :type

  enum :status, {
    active:   0,
    inactive: 1
  }, prefix: true

  # ── Validations ────────────────────────────────────────────────
  validates :full_name,     presence: true
  validates :employee_type, presence: true
  validates :status,        presence: true
  validates :base_salary,   numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  normalizes :email, with: ->(e) { e.strip.downcase } if method_defined?(:email)

  # ── Scopes ─────────────────────────────────────────────────────
  scope :active,   -> { where(status: :active) }
  scope :coaches,  -> { where(employee_type: [:coach, :assistant_coach]) }
  scope :ordered,  -> { order(:full_name) }

  # ── Instance helpers ───────────────────────────────────────────
  def display_type
    employee_type.to_s.humanize
  end

  # Generate the salary for this employee for a given month/year.
  # Idempotent — returns existing record if already created.
  def generate_salary_for(month:, year:)
    salaries.find_or_create_by!(
      academy: academy,
      month:   month,
      year:    year
    ) do |s|
      s.amount = base_salary
    end
  end
end
