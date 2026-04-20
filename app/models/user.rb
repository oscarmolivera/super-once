class User < ApplicationRecord
  has_secure_password

  has_many :sessions, dependent: :destroy
  has_many :memberships, dependent: :destroy
  has_many :academies, through: :memberships

  # ── Validations ──────────────────────────────────────────────
  validates :email_address,
    presence: true,
    uniqueness: { case_sensitive: false },
    format: { with: URI::MailTo::EMAIL_REGEXP }

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  # ── Superadmin flag ──────────────────────────────────────────
  # Superadmins access admin.nubbe.net and are NOT tied to any academy.
  # Use sparingly — grant via rails console only.
  def superadmin?
    superadmin
  end

  # ── Academy helpers ──────────────────────────────────────────
  def member_of?(academy)
    academies.include?(academy)
  end

  def role_in(academy)
    memberships.find_by(academy: academy)&.role
  end

  def owner_of?(academy)
    role_in(academy) == "owner"
  end

  def admin_of?(academy)
    %w[owner admin].include?(role_in(academy))
  end
end