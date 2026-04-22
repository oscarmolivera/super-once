class Academy < ApplicationRecord
  # This IS the tenant. Every model calls `acts_as_tenant(:academy)`.
  # ── Associations ────────────────────────────────────────────────
  has_one :subscription, dependent: :destroy
  has_one :plan, through: :subscription
  has_many :memberships,    dependent: :destroy
  has_many :users,          through: :memberships
  has_many :invitations,    dependent: :destroy

  # Enterprise pillar
  has_many :employees,       dependent: :destroy
  has_many :salaries,        dependent: :destroy
  has_many :income_expenses, dependent: :destroy
  has_many :player_payments, dependent: :destroy
  has_many :inventory_items, dependent: :destroy
  has_many :tax_permits,     dependent: :destroy

  # School pillar
  has_many :sport_schools,       dependent: :destroy
  has_many :categories,          dependent: :destroy
  has_many :players,             dependent: :destroy
  has_many :category_enrollments, dependent: :destroy
  has_many :coach_assignments,    dependent: :destroy
  has_many :practice_sessions,    dependent: :destroy
  has_many :attendance_records,   dependent: :destroy
  has_many :training_plans,       dependent: :destroy
  has_many :announcements,        dependent: :destroy

  # Club pillar
  has_many :cups,        dependent: :destroy
  has_many :tournaments, dependent: :destroy
  has_many :cup_teams,   dependent: :destroy
  has_many :team_players, dependent: :destroy
  has_many :matches,     dependent: :destroy

  # ── Validations ─────────────────────────────────────────────────
  validates :name, presence: true
  validates :slug,
    presence: true,
    uniqueness: { case_sensitive: false },
    format: { with: /\A[a-z0-9\-]+\z/, message: "only lowercase letters, numbers and hyphens" },
    length: { minimum: 3, maximum: 63 }

  RESERVED_SLUGS = %w[www admin api mail assets static].freeze
  validate :slug_not_reserved

  # ── Scopes ──────────────────────────────────────────────────────
  scope :active,    -> { where(status: :active) }
  scope :on_trial,  -> { where(status: :trial) }
  scope :suspended, -> { where(status: :suspended) }

  # ── Enums ───────────────────────────────────────────────────────
  enum :status, { trial: 0, active: 1, suspended: 2, cancelled: 3 }, prefix: true
  enum :plan,   { free: 0, starter: 1, pro: 2, enterprise: 3 }

  # ── Callbacks ───────────────────────────────────────────────────
  before_validation :normalize_slug

  # ── Instance helpers ────────────────────────────────────────────
  def subdomain   = slug
  def full_domain(tld = "nubbe.net") = "#{slug}.#{tld}"
  def owner       = memberships.owner.first&.user

  private

  def normalize_slug
    self.slug = slug.to_s.downcase.strip.gsub(/\s+/, "-")
  end

  def slug_not_reserved
    errors.add(:slug, "is reserved and cannot be used") if RESERVED_SLUGS.include?(slug.to_s.downcase)
  end
end
