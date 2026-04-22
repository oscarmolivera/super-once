class IncomeExpense < ApplicationRecord
  acts_as_tenant(:academy)

  belongs_to :academy

  # ── Enums ──────────────────────────────────────────────────────
  enum :kind, { income: 0, expense: 1 }, prefix: true

  enum :category, {
    # Income categories
    player_fees:    0,
    sponsorship:    1,
    grant:          2,
    merchandise:    3,
    # Expense categories
    rent:           10,
    utilities:      11,
    equipment:      12,
    travel:         13,
    insurance:      14,
    maintenance:    15,
    # Shared
    other:          99
  }, prefix: true

  # ── Validations ────────────────────────────────────────────────
  validates :kind,        presence: true
  validates :amount,      presence: true,
                          numericality: { greater_than: 0 }
  validates :description, presence: true
  validates :recorded_on, presence: true

  # ── Scopes ─────────────────────────────────────────────────────
  scope :income,    -> { where(kind: :income) }
  scope :expenses,  -> { where(kind: :expense) }
  scope :this_month, -> {
    where(recorded_on: Date.current.beginning_of_month..Date.current.end_of_month)
  }
  scope :for_year,  ->(year) {
    where(recorded_on: Date.new(year, 1, 1)..Date.new(year, 12, 31))
  }
  scope :recent,    -> { order(recorded_on: :desc) }

  # ── Class helpers ──────────────────────────────────────────────
  def self.balance_for(relation = all)
    total_income  = relation.income.sum(:amount)
    total_expense = relation.expenses.sum(:amount)
    total_income - total_expense
  end
end
