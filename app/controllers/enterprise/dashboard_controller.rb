module Enterprise
  class DashboardController < Enterprise::BaseController
    def index
      authorize :enterprise_dashboard, :index?

      current_month = Date.current.month
      current_year  = Date.current.year

      employees_scope     = policy_scope(Employee)
      @total_employees    = employees_scope.active.count
      @coaches_count      = employees_scope.active.coaches.count

      @salaries_this_month = policy_scope(Salary).for_period(current_month, current_year)
      @payroll_total       = @salaries_this_month.sum(:amount)
      @payroll_pending     = @salaries_this_month.pending.sum(:amount)

      month_ledger         = policy_scope(IncomeExpense).this_month
      @income_this_month   = month_ledger.income.sum(:amount)
      @expense_this_month  = month_ledger.expenses.sum(:amount)
      @balance_this_month  = @income_this_month - @expense_this_month

      payments_scope       = policy_scope(PlayerPayment)
      @overdue_payments    = payments_scope.overdue.count
      @pending_payments    = payments_scope.pending.count

      permits_scope        = policy_scope(TaxPermit)
      @expiring_permits    = permits_scope.expiring_soon.count
      @expired_permits     = permits_scope.expired.count

      @recent_entries      = policy_scope(IncomeExpense).recent.limit(8)
    end
  end
end
