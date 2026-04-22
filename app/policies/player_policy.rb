class PlayerPolicy < ApplicationPolicy
  def new?
    member?
  end

  def create?
    member?
  end

  def show?
    member?
  end

  def edit?
    member?
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

      category_ids = CategoryPolicy::Scope
        .new(PunditContext.new(user: user, academy: academy, role: role), Category)
        .resolve
        .select(:id)

      scope.joins(:category_enrollments).where(category_enrollments: { category_id: category_ids }).distinct
    end

    private

    def admin?
      role == "owner" || role == "admin"
    end
  end
end

