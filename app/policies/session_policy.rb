class SessionPolicy < ApplicationPolicy
  def destroy?
    true
  end

  def new?
    true
  end
end