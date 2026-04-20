class DashboardController < ApplicationController
  def index
    # Pundit: every action must be authorized.
    # Dashboard index is accessible to all academy members.
    authorize :dashboard, :index?

    @academy        = current_academy
    @membership     = current_membership
    @members_count  = policy_scope(Membership).count

    # Pillar summary counts — these will grow as we build Phases 3-5.
    # Stubbed as zero for now so the view renders without errors.
    @employees_count = 0
    @players_count   = 0
    @cups_count      = 0
  end
end
