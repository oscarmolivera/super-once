class CategoryPolicy < ApplicationPolicy
  def show?
    member_in_category?
  end

  def edit?
    admin? || coach_in_category?
  end

  def update?
    edit?
  end

  def destroy?
    owner?
  end

  class Scope < Scope
    def resolve
      return scope.all if admin?

      employee = Employee.find_by(academy: academy, user: user)
      return scope.none unless employee

      scope.joins(:coach_assignments).where(coach_assignments: { employee_id: employee.id }).distinct
    end

    private

    def admin?
      role == "owner" || role == "admin"
    end
  end

  private

  def member_in_category?
    admin? || coach_in_category?
  end

  def coach_in_category?
    return false unless user && academy
    employee = Employee.find_by(academy: academy, user: user)
    return false unless employee
    record.coach_assignments.exists?(employee_id: employee.id)
  end
end

