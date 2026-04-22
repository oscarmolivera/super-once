class InventoryItemPolicy < ApplicationPolicy
  def index?
    member? # All staff can see inventory
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
    admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end

