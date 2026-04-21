class Academy < ApplicationRecord
  # This IS the tenant. Every model that belongs to an academy
  # calls `acts_as_tenant(:academy)` and gets automatic account scoping.
  has_many :memberships,  dependent: :destroy
  has_many :users,        through: :memberships
  has_many :invitations,  dependent: :destroy

  # ── Validations ──────────────────────────────────────────────
  validates :name, presence: true
  validates :slug,
    presence: true,
    uniqueness: { case_sensitive: false },
    format: { with: /\A[a-z0-9\-]+\z/, message: "only lowercase letters, numbers and hyphens" },
    length: { minimum: 3, maximum: 63 }

  # Reserved subdomains that cannot be used as academy slugs
  RESERVED_SLUGS = %w[www admin api mail assets static].freeze
  validate :slug_not_reserved

  # ── Scopes ───────────────────────────────────────────────────
  scope :active,    -> { where(status: :active) }
  scope :on_trial,  -> { where(status: :trial) }
  scope :suspended, -> { where(status: :suspended) }

  # ── Enums ────────────────────────────────────────────────────
  enum :status, { trial: 0, active: 1, suspended: 2, cancelled: 3 }, prefix: true
  enum :plan,   { free: 0, starter: 1, pro: 2, enterprise: 3 }

  # ── Callbacks ────────────────────────────────────────────────
  before_validation :normalize_slug

  # ── Instance helpers ─────────────────────────────────────────
  def subdomain
    slug
  end

  def full_domain(tld = "nubbe.net")
    "#{slug}.#{tld}"
  end

  def owner
    memberships.owner.first&.user
  end

  private

  def normalize_slug
    self.slug = slug.to_s.downcase.strip.gsub(/\s+/, "-")
  end

  def slug_not_reserved
    errors.add(:slug, "is reserved and cannot be used") if RESERVED_SLUGS.include?(slug.to_s.downcase)
  end
end
