class AnnouncementPolicy < ApplicationPolicy
  def new?
    member?
  end

  def create?
    return true if admin?

    # Academy-wide announcements should be admin-only.
    return false if record.category_id.nil?

    coach_for_category?
  end

  def show?
    member?
  end

  def edit?
    admin? || coach_for_category?
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

      scope.where(category_id: nil).or(scope.where(category_id: category_ids))
    end

    private

    def admin?
      role == "owner" || role == "admin"
    end
  end

  private

  def coach_for_category?
    return false if record.category_id.nil?
    CategoryPolicy.new(PunditContext.new(user: user, academy: academy, role: role), record.category).edit?
  end
end

