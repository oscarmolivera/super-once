class Membership < ApplicationRecord
  # NOTE: Membership itself is NOT tenant-scoped via acts_as_tenant.
  # It IS the tenant ↔ user bridge. Scoping it would create a chicken-and-egg
  # problem when resolving who belongs to an academy on login.
  belongs_to :academy
  belongs_to :user

  # ── Enums ────────────────────────────────────────────────────
  # Hierarchy: owner > admin > member
  # Owners can do everything, including transfer ownership and delete the academy.
  # Admins manage operations but cannot touch billing or delete the academy.
  # Members (coaches, staff) have read + scoped write access per Pundit policies.
  enum :role, { member: 0, admin: 1, owner: 2 }

  # ── Validations ──────────────────────────────────────────────
  validates :academy_id, uniqueness: { scope: :user_id, message: "user is already a member" }
  validates :role, presence: true

  # ── Scopes ───────────────────────────────────────────────────
  scope :owners,  -> { where(role: :owner) }
  scope :admins,  -> { where(role: :admin) }
  scope :members, -> { where(role: :member) }

  # ── Guards ───────────────────────────────────────────────────
  # Prevent removing the last owner — academy would become ownerless.
  before_destroy :prevent_last_owner_removal

  private

  def prevent_last_owner_removal
    if owner? && academy.memberships.owners.count <= 1
      errors.add(:base, "Cannot remove the only owner of an academy")
      throw(:abort)
    end
  end
end
