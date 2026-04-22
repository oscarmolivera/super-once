class TournamentPolicy < ApplicationPolicy
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
    owner?
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end

