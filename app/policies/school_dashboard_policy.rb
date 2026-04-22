# Pundit policy for the School::DashboardController.
# Called via: authorize :school_dashboard, :index?
class SchoolDashboardPolicy < ApplicationPolicy
  def index?
    member?
  end
end

