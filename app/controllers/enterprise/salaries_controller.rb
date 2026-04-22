module Enterprise
  class SalariesController < Enterprise::BaseController
    before_action :set_salary, only: %i[show edit update destroy]

    def index
      # Default to current month; allow ?month=&year= params
      @month = (params[:month] || Date.current.month).to_i
      @year  = (params[:year]  || Date.current.year).to_i

      @salaries = policy_scope(Salary)
        .for_period(@month, @year)
        .includes(:employee)
        .order("employees.full_name")

      @total_amount   = @salaries.sum(:amount)
      @pending_amount = @salaries.pending.sum(:amount)
      @paid_amount    = @salaries.paid.sum(:amount)
    end

    def show
      authorize @salary
    end

    def new
      @salary = Salary.new(
        month: Date.current.month,
        year:  Date.current.year
      )
      @employees = Employee.active.ordered
      authorize @salary
    end

    def create
      @salary = Salary.new(salary_params)
      authorize @salary

      if @salary.save
        redirect_to enterprise_salaries_path,
          notice: "Salary entry created for #{@salary.employee.full_name}."
      else
        @employees = Employee.active.ordered
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize @salary
      @employees = Employee.active.ordered
    end

    def update
      authorize @salary

      if @salary.update(salary_params)
        redirect_to enterprise_salaries_path,
          notice: "Salary entry updated."
      else
        @employees = Employee.active.ordered
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @salary
      @salary.destroy
      redirect_to enterprise_salaries_path, notice: "Salary entry removed."
    end

    # POST /enterprise/salaries/generate_month
    # Bulk-create salary entries for all active employees for a given period.
    def generate_month
      authorize Salary, :create?

      month = (params[:month] || Date.current.month).to_i
      year  = (params[:year]  || Date.current.year).to_i

      generated = 0
      Employee.active.find_each do |employee|
        unless Salary.exists?(academy: current_academy, employee: employee, month: month, year: year)
          Salary.create!(
            academy:  current_academy,
            employee: employee,
            month:    month,
            year:     year,
            amount:   employee.base_salary || 0
          )
          generated += 1
        end
      end

      redirect_to enterprise_salaries_path(month: month, year: year),
        notice: "Generated #{generated} salary entries for #{Date.new(year, month).strftime('%B %Y')}."
    end

    private

    def set_salary
      @salary = policy_scope(Salary).find(params[:id])
    end

    def salary_params
      params.require(:salary).permit(
        :employee_id, :amount, :month, :year, :status, :paid_on, :notes
      )
    end
  end
end
