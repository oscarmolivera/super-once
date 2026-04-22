# Policy for the Academy model itself.
# Used by AcademySettingsController via `authorize @academy, :settings_show?` etc.
class AcademyPolicy < ApplicationPolicy
  # All members can view academy settings (read-only overview)
  def settings_show?  = member?

  # Only admin and above can edit
  def settings_edit?   = admin?
  def settings_update? = admin?

  # Only owner can delete the academy entirely (Phase 6 concern)
  def destroy? = owner?

  # Billing authorization (Phase 6)
  def manage_billing? = owner?
  def view_billing?   = admin?
  def upgrade_plan?   = owner? && !record.subscription&.plan&.pro?
  def downgrade_plan? = owner? && record.subscription&.plan&.free? == false
  def cancel_subscription? = owner?

  class Scope < ApplicationPolicy::Scope
    def resolve = scope.all
  end
end
