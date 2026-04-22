# Academy subscription to a Plan
# Tracks billing, trial, and Stripe integration
class Subscription < ApplicationRecord
  belongs_to :academy
  belongs_to :plan

  # ── Enums ───────────────────────────────────────────────────
  enum :status, { active: 'active', paused: 'paused', canceled: 'canceled', past_due: 'past_due' }
  enum :billing_cycle, { monthly: 'monthly', annual: 'annual' }

  # ── Validations ─────────────────────────────────────────────
  validates :academy_id, uniqueness: true
  validates :plan_id, presence: true
  validates :status, presence: true
  validates :current_period_start, :current_period_end, presence: true

  # ── Scopes ──────────────────────────────────────────────────
  scope :active_subscriptions, -> { where(status: :active) }
  scope :on_trial, -> { where("trial_ends_at > ?", Time.current) }
  scope :expired_trials, -> { where("trial_ends_at <= ?", Time.current).where(status: :active) }
  scope :expiring_soon, -> { where("trial_ends_at BETWEEN ? AND ?", Time.current, 3.days.from_now) }

  # ── Instance Methods ────────────────────────────────────────

  # Check if subscription is currently in trial period
  def trialing?
    trial_ends_at.present? && trial_ends_at > Time.current
  end

  # Check if trial is expiring in N days
  def trial_expiring_soon?(days = 3)
    trialing? && trial_ends_at <= days.days.from_now
  end

  # Days remaining in trial
  def trial_days_remaining
    return 0 unless trialing?
    ((trial_ends_at - Time.current) / 1.day).ceil
  end

  # Generate Stripe subscription data for checkout
  def stripe_checkout_session_params
    {
      customer: stripe_customer_id,
      line_items: [{
        price: plan.stripe_price_id,
        quantity: 1
      }],
      mode: 'subscription',
      success_url: "#{Rails.application.routes.url_helpers.tenant_root_url(subdomain: academy.slug)}?session_id={CHECKOUT_SESSION_ID}",
      cancel_url: "#{Rails.application.routes.url_helpers.tenant_root_url(subdomain: academy.slug)}"
    }
  end

  # Return MRR (Monthly Recurring Revenue) for this subscription
  def mrr
    return 0 unless active?
    plan.price_cents / 100.0
  end
end
