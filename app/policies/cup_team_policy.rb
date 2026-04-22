class CupTeamPolicy < ApplicationPolicy
  def index?
    member?
  end

  def show?
    member_in_category?
  end

  def new?
    member?
  end

  def create?
    return true if admin?
    return false unless record.category
    CategoryPolicy.new(context, record.category).edit?
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

  def roster_edit?
    edit?
  end

  def roster_update?
    roster_edit?
  end

  class Scope < Scope
    def resolve
      return scope.all if admin?

      employee = Employee.find_by(academy: academy, user: user)
      return scope.none unless employee

      scope.joins(category: :coach_assignments)
        .where(coach_assignments: { employee_id: employee.id })
        .distinct
    end

    private

    def admin?
      role == "owner" || role == "admin"
    end
  end

  private

  def context
    PunditContext.new(user: user, academy: academy, role: role)
  end

  def member_in_category?
    admin? || coach_in_category?
  end

  def coach_in_category?
    return false unless user && academy && record.category
    CategoryPolicy.new(context, record.category).show?
  end
end

