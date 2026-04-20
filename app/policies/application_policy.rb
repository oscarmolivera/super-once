# All Pundit policies inherit from this base.
#
# The `context` object is a PunditContext (not a raw User), containing:
#   context.user    — the logged-in User record
#   context.academy — the current Academy tenant
#   context.role    — "owner" | "admin" | "member" (already resolved, no DB hit)
#
# Role hierarchy:
#   owner  → can do everything, including destroy and billing actions
#   admin  → full CRUD on business data, cannot touch billing/ownership
#   member → read + their own scoped write actions (defined per policy)

class ApplicationPolicy
  attr_reader :user, :academy, :role, :record

  def initialize(context, record)
    # Support both PunditContext objects and raw User objects (e.g. in tests
    # or superadmin contexts where there's no tenant).
    if context.is_a?(PunditContext)
      @user    = context.user
      @academy = context.academy
      @role    = context.role
    else
      @user    = context
      @academy = nil
      @role    = nil
    end

    @record = record
  end

  # Default CRUD gates — override in subclasses as needed.
  def index?   = member?
  def show?    = member?
  def new?     = admin?
  def create?  = admin?
  def edit?    = admin?
  def update?  = admin?
  def destroy? = owner?

  class Scope
    def initialize(context, scope)
      if context.is_a?(PunditContext)
        @user    = context.user
        @academy = context.academy
        @role    = context.role
      else
        @user = context
      end
      @scope = scope
    end

    # acts_as_tenant already applies the academy_id WHERE clause automatically.
    # Subclass scopes only need to add further filtering (e.g. hide draft records
    # from members, or restrict a coach to their assigned categories).
    def resolve
      @scope.all
    end

    private

    attr_reader :user, :academy, :role, :scope
  end

  protected

  # ── Role helpers ─────────────────────────────────────────────
  # These are the only place in the codebase where role strings are
  # compared. All policies use these methods, never raw string checks.

  def owner?
    role == "owner"
  end

  def admin?
    owner? || role == "admin"
  end

  def member?
    admin? || role == "member"
  end

  def authenticated?
    user.present?
  end
end
