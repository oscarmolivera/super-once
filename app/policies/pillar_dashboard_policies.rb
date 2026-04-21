# Symbol-backed policies for the three pillar stub dashboards.
# These will grow into full resource policies in Phases 3-5.
# For now they just gate access to the pillar root page.

class EnterpriseDashboardPolicy < ApplicationPolicy
  def index? = member?
end

class SchoolDashboardPolicy < ApplicationPolicy
  def index? = member?
end

class ClubDashboardPolicy < ApplicationPolicy
  def index? = member?
end
