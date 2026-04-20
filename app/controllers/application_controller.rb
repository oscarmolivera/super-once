class ApplicationController < ActionController::Base
  include Authentication   # Rails 8 generated concern
  include Pundit::Authorization

  # ── Tenant resolution ─────────────────────────────────────────
  # ORDER MATTERS:
  #
  #   1. set_current_academy       — finds Academy by slug. No session needed.
  #                                  Safe to run on the login page itself.
  #
  #   2. require_authentication    — Rails 8 generated name (NOT authenticate_user!).
  #                                  Redirects to new_session_path if no session.
  #                                  SessionsController and PasswordsController call
  #                                  allow_unauthenticated_access to skip this.
  #
  #   3. verify_tenant_membership  — confirms Current.user belongs to this academy.
  #                                  Only runs after a session is confirmed.
  #
  before_action :set_current_academy,      if: :tenant_subdomain?
  before_action :require_authentication,   if: :tenant_subdomain?
  before_action :verify_tenant_membership, if: :tenant_subdomain?

  # ── Pundit audit ─────────────────────────────────────────────
  after_action :verify_authorized,    except: :index, if: :tenant_subdomain?
  after_action :verify_policy_scoped, only:   :index, if: :tenant_subdomain?

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  # ── Helpers ──────────────────────────────────────────────────
  helper_method :current_academy, :current_membership

  private

  # ── Step 1: resolve tenant from subdomain ────────────────────
  # Never calls Current.user — safe before any session check.
  def set_current_academy
    slug = request.subdomain.presence
    @current_academy = Academy.find_by(slug: slug)

    unless @current_academy
      redirect_to "https://www.nubbe.net", alert: "Academy not found."
      return
    end

    ActsAsTenant.current_tenant = @current_academy
  end

  # ── Step 3: confirm session user is a member of this academy ─
  def verify_tenant_membership
    return if Current.user&.member_of?(@current_academy)

    redirect_to new_session_path,
      alert: "You don't have access to #{@current_academy.name}."
  end

  def current_academy
    @current_academy
  end

  # Memoised — DB hit once per request cycle only.
  def current_membership
    return nil unless Current.user && current_academy

    @current_membership ||= Current.user
      .memberships
      .find_by!(academy: current_academy)
  end

  # ── Pundit context ───────────────────────────────────────────
  # Pass PunditContext so policies receive the resolved role — no extra DB hit.
  def pundit_user
    return Current.user unless current_academy

    PunditContext.new(
      user:    Current.user,
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
