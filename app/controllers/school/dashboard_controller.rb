module School
  class DashboardController < School::BaseController
    def index
      authorize :school_dashboard, :index?
      @categories = policy_scope(Category).includes(:sport_school).order(:name)
      @upcoming_sessions = policy_scope(PracticeSession)
        .includes(:category)
        .where("starts_at >= ?", Time.current.beginning_of_day)
        .order(:starts_at)
        .limit(10)
    end
  end
end
