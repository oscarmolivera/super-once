class MembershipPolicy < ApplicationPolicy
  def index?   = admin?
  def new?     = admin?
  def create?  = admin?

  # Only owners can change another user's role.
  def update?  = owner?

  # Admins can remove members. Owners can remove anyone (except last owner —
  # enforced at the model layer via before_destroy callback).
  def destroy?
    return true if owner?
    return true if admin? && !record.owner?
    false
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.where(academy: academy)
    end
  end
end
