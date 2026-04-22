module Enterprise
  class IncomeExpensesController < Enterprise::BaseController
    before_action :set_entry, only: %i[show edit update destroy]

    def index
      @year  = (params[:year] || Date.current.year).to_i
      @kind  = params[:kind].presence  # "income" | "expense" | nil

      scope = policy_scope(IncomeExpense).for_year(@year).recent
      scope = scope.where(kind: @kind) if @kind.present?

      @entries        = scope
      @total_income   = policy_scope(IncomeExpense).for_year(@year).income.sum(:amount)
      @total_expenses = policy_scope(IncomeExpense).for_year(@year).expenses.sum(:amount)
      @balance        = @total_income - @total_expenses
    end

    def show
      authorize @entry
    end

    def new
      @entry = IncomeExpense.new(
        recorded_on: Date.current,
        kind:        params[:kind] || :income
      )
      authorize @entry
    end

    def create
      @entry = IncomeExpense.new(entry_params)
      authorize @entry

      if @entry.save
        redirect_to enterprise_income_expenses_path,
          notice: "Entry recorded."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize @entry
    end

    def update
      authorize @entry

      if @entry.update(entry_params)
        redirect_to enterprise_income_expenses_path,
          notice: "Entry updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @entry
      @entry.destroy
      redirect_to enterprise_income_expenses_path,
        notice: "Entry removed."
    end

    private

    def set_entry
      @entry = policy_scope(IncomeExpense).find(params[:id])
    end

    def entry_params
      params.require(:income_expense).permit(
        :kind, :amount, :description, :category, :recorded_on, :reference
      )
    end
  end
end
