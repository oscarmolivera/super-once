class TeamPlayerPolicy < ApplicationPolicy
  def upsert?
    CupTeamPolicy.new(context, record.cup_team).roster_update?
  end

  class Scope < Scope
    def resolve
      return scope.all if admin?

      team_ids = CupTeamPolicy::Scope
        .new(PunditContext.new(user: user, academy: academy, role: role), CupTeam)
        .resolve
        .select(:id)

      scope.where(cup_team_id: team_ids)
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

