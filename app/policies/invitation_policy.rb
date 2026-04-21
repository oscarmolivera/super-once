class InvitationPolicy < ApplicationPolicy
  # Only admins and owners can invite new members
  def new?    = admin?
  def create? = admin?

  # Admins can see pending invitations list
  def index?  = admin?

  # Only owners can revoke / destroy pending invitations
  def destroy? = owner?

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.pending
    end
  end
end
