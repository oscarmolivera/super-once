# Pundit does not require the "user" passed to policies to literally be a User.
# We pass a PunditContext that bundles all three things a policy needs:
#   - the user record
#   - the current academy (tenant)
#   - the resolved membership role as a string ("owner", "admin", "member")
#
# This means policies never hit the DB for role lookups — the role is already
# resolved in ApplicationController#pundit_user before any policy runs.
#
# Usage in policies:
#   def initialize(context, record)
#     @user    = context.user
#     @academy = context.academy
#     @role    = context.role   # "owner" | "admin" | "member"
#     @record  = record
#   end

PunditContext = Data.define(:user, :academy, :role)
