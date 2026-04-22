class PracticeSessionPolicy < ApplicationPolicy
  def new?
    member?
  end

  def create?
    return true if admin?
    return false unless record.category
    CategoryPolicy.new(context, record.category).edit?
  end

  def show?
    CategoryPolicy.new(context, record.category).show?
  end

  def edit?
    CategoryPolicy.new(context, record.category).edit?
  end

  def update?
    edit?
  end

  def destroy?
    owner?
  end

  def attendance?
    CategoryPolicy.new(context, record.category).edit?
  end

  def upsert_attendance?
    attendance?
  end

  class Scope < Scope
    def resolve
      return scope.all if admin?

      category_ids = CategoryPolicy::Scope.new(PunditContext.new(user: user, academy: academy, role: role), Category).resolve.select(:id)
      scope.where(category_id: category_ids)
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
end

