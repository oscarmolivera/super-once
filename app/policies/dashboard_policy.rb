# Pundit policy for the :dashboard symbol (not a model-backed resource).
# Called via: authorize :dashboard, :index?
class DashboardPolicy < ApplicationPolicy
  def index? = member?
end
