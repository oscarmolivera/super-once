class Invitation < ApplicationRecord
  # Invitations ARE tenant-scoped — an invitation belongs to one academy.
  acts_as_tenant(:academy)

  belongs_to :academy
  belongs_to :invited_by, class_name: "User"

  enum :role, { member: 0, admin: 1, owner: 2 }

  # ── Validations ──────────────────────────────────────────────
  validates :email,      presence: true,
                         format: { with: URI::MailTo::EMAIL_REGEXP },
                         uniqueness: { scope: :academy_id, message: "already has a pending invitation" }
  validates :token,      presence: true, uniqueness: true
  validates :expires_at, presence: true

  normalizes :email, with: ->(e) { e.strip.downcase }

  # ── Callbacks ────────────────────────────────────────────────
  before_validation :generate_token, on: :create
  before_validation :set_expiry,     on: :create

  # ── Scopes ───────────────────────────────────────────────────
  scope :pending,  -> { where(accepted_at: nil).where("expires_at > ?", Time.current) }
  scope :expired,  -> { where("expires_at <= ?", Time.current).where(accepted_at: nil) }
  scope :accepted, -> { where.not(accepted_at: nil) }

  # ── Instance helpers ─────────────────────────────────────────
  def pending?
    accepted_at.nil? && expires_at > Time.current
  end

  def expired?
    expires_at <= Time.current && accepted_at.nil?
  end

  def accepted?
    accepted_at.present?
  end

  def accept!(user)
    return false unless pending?

    ActiveRecord::Base.transaction do
      Membership.create!(academy: academy, user: user, role: role)
      update!(accepted_at: Time.current)
    end

    true
  rescue ActiveRecord::RecordInvalid
    false
  end

  private

  def generate_token
    self.token = SecureRandom.urlsafe_base64(32)
  end

  def set_expiry
    self.expires_at = 7.days.from_now
  end
end
