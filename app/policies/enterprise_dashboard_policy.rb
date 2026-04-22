# Pundit policy for the Enterprise::DashboardController.
# Called via: authorize :enterprise_dashboard, :index?
class EnterpriseDashboardPolicy < ApplicationPolicy
  def index? = member?
end
