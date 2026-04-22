# Employees: coaches should be able to view the employee list (e.g. to see colleagues)
# but NOT their colleagues' salaries. Salary visibility is admin+ only.
class EmployeePolicy < ApplicationPolicy
  def index?
    member?
  end

  def show?
    member?
  end

  def new?
    admin?
  end

  def create?
    admin?
  end

  def edit?
    admin?
  end

  def update?
    admin?
  end

  def destroy?
    admin? # admin can remove employees (not just owner)
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end

