module Club
  class DashboardController < Club::BaseController
    def index
      authorize :club_dashboard, :index?

      @tournaments = policy_scope(Tournament).includes(:cup).order(year: :desc).limit(6)
      @cup_teams   = policy_scope(CupTeam).includes(tournament: :cup, category: :sport_school).order(created_at: :desc).limit(6)
      @upcoming_matches = policy_scope(Match)
        .includes(:cup_team, tournament: :cup)
        .where("starts_at >= ?", Time.current.beginning_of_day)
        .order(:starts_at)
        .limit(10)
    end
  end
end
