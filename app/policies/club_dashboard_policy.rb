# Pundit policy for the Club::DashboardController.
# Called via: authorize :club_dashboard, :index?
class ClubDashboardPolicy < ApplicationPolicy
  def index?
    member?
  end
end

