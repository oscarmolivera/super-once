class ApplicationController < ActionController::Base
  include Authentication   # Rails 8 generated concern
  include Pundit::Authorization

  # ── Tenant resolution ─────────────────────────────────────────
  # Runs on every request to a tenant subdomain.
  # www and admin subdomains are handled by their own base controllers
  # and never hit this before_action.
  before_action :set_current_academy, if: :tenant_subdomain?
  before_action :authenticate_user!,  if: :tenant_subdomain?

  # ── Pundit audit ─────────────────────────────────────────────
  after_action :verify_authorized,     except: :index, if: :tenant_subdomain?
  after_action :verify_policy_scoped,  only:   :index, if: :tenant_subdomain?

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  # ── Helpers ──────────────────────────────────────────────────
  helper_method :current_academy, :current_membership

  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  private

  # ── Tenant setup ─────────────────────────────────────────────
  def set_current_academy
    slug = request.subdomain.presence

    @current_academy = Academy.find_by(slug: slug)

    unless @current_academy
      redirect_to "https://www.nubbe.net", alert: "Academy not found."
      return
    end

    unless current_user && current_user.member_of?(@current_academy)
      redirect_to new_session_path, alert: "You don't have access to this academy."
      return
    end

    ActsAsTenant.current_tenant = @current_academy
  end

  def current_academy
    @current_academy
  end

  # Memoized so the DB is hit only once per request cycle.
  def current_membership
    return nil unless current_user && current_academy

    @current_membership ||= current_user
      .memberships
      .find_by!(academy: current_academy)
  end

  # ── Pundit context ───────────────────────────────────────────
  # Override Pundit's default `pundit_user` to pass a context object
  # instead of just the user. This encodes the resolved role so that
  # policies never need a DB round-trip to check the role.
  def pundit_user
    return current_user unless current_academy

    PunditContext.new(
      user:    current_user,
      academy: current_academy,
      role:    current_membership&.role.to_s
    )
  end

  # ── Subdomain helpers ────────────────────────────────────────
  def tenant_subdomain?
    sub = request.subdomain.presence
    sub.present? && !%w[www admin].include?(sub)
  end

  # ── Error handlers ───────────────────────────────────────────
  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_back_or_to tenant_root_path
  end
end

