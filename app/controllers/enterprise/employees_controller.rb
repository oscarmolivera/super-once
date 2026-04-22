module Enterprise
  class EmployeesController < Enterprise::BaseController
    before_action :set_employee, only: %i[show edit update destroy]

    def index
      @employees = policy_scope(Employee).ordered.includes(:salaries)
      @by_type   = @employees.group_by(&:employee_type)
    end

    def show
      authorize @employee
      @recent_salaries = @employee.salaries.order(year: :desc, month: :desc).limit(6)
    end

    def new
      @employee = Employee.new
      authorize @employee
    end

    def create
      @employee = Employee.new(employee_params)
      authorize @employee

      if @employee.save
        redirect_to enterprise_employee_path(@employee),
          notice: "#{@employee.full_name} added to the team."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize @employee
    end

    def update
      authorize @employee

      if @employee.update(employee_params)
        redirect_to enterprise_employee_path(@employee),
          notice: "#{@employee.full_name} updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @employee
      name = @employee.full_name
      @employee.destroy
      redirect_to enterprise_employees_path,
        notice: "#{name} removed."
    end

    private

    def set_employee
      @employee = policy_scope(Employee).find(params[:id])
    end

    def employee_params
      params.require(:employee).permit(
        :full_name, :email, :phone, :employee_type,
        :status, :hire_date, :birth_date,
        :document_number, :base_salary, :notes
      )
    end
  end
end
