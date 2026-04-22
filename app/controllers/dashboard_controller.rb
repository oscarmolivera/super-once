class DashboardController < ApplicationController
  def index
    authorize :dashboard, :index?

    @academy       = current_academy
    @membership    = current_membership
    @members_count = policy_scope(Membership).count

    # Enterprise counts — only loaded for admin+ to avoid
    # exposing financial summary to member-role users.
    if current_membership&.admin? || current_membership&.owner?
      @employees_count    = Employee.active.count
      @overdue_payments   = PlayerPayment.overdue.count
      month_ledger        = IncomeExpense.this_month
      @income_this_month  = month_ledger.income.sum(:amount)
      @expense_this_month = month_ledger.expenses.sum(:amount)
      @balance_this_month = @income_this_month - @expense_this_month
    else
      @employees_count    = Employee.active.count  # visible to all
      @overdue_payments   = 0
      @income_this_month  = 0
      @expense_this_month = 0
      @balance_this_month = 0
    end

    # Phase 4 — will be real counts once School pillar is built
    @players_count = 0

    # Phase 5 — will be real counts once Club pillar is built
    @cups_count = 0
  end
end
