# SaaS Billing + Onboarding Implementation Guide

## Architecture Overview

Phase 6 implements a complete SaaS billing system with three-tier plans, Stripe integration, and an automated onboarding flow.

### Key Components

1. **Plans** - Free, Starter, Pro tiers with feature gating
2. **Subscriptions** - Track billing, trials, and status per academy
3. **Onboarding Flow** - 5-step wizard for new academies
4. **Feature Gating** - Pundit policies restrict features by plan
5. **Billing Portal** - Academy owners manage subscriptions
6. **Superadmin Dashboard** - Revenue, churn, and metrics

---

## Setup Instructions

### 1. Install Dependencies

```bash
bundle install
```

The Gemfile now includes:
- `stripe` - Stripe payment processing
- `stripe_event` - Webhook handling

### 2. Configure Stripe

Add your Stripe keys to `config/credentials.yml.enc`:

```bash
EDITOR=nano rails credentials:edit
```

Add:
```yaml
stripe:
  secret_key: sk_live_... or sk_test_...
  webhook_secret: whsec_...
```

### 3. Create Stripe Products and Prices

In your Stripe Dashboard:

1. Create 3 products:
   - Free (no price needed)
   - Starter ($49.99/month)
   - Pro ($99.99/month)

2. Get product IDs and price IDs

3. Add to credentials:
```yaml
stripe:
  secret_key: sk_test_...
  webhook_secret: whsec_...
  product_free: prod_...
  price_free: price_...
  product_starter: prod_...
  price_starter: price_...
  product_pro: prod_...
  price_pro: price_...
```

### 4. Run Migrations

```bash
rails db:migrate
```

This creates:
- `plans` table
- `subscriptions` table

### 5. Seed Plans

```bash
rails db:seed:plans
```

This creates the three plan tiers with features.

### 6. Set Up Stripe Webhooks

In Stripe Dashboard → Developers → Webhooks:

1. Add endpoint: `https://yourdomain.com/stripe/webhooks`
2. Subscribe to events:
   - `customer.subscription.updated`
   - `customer.subscription.deleted`
   - `invoice.payment_succeeded`
   - `invoice.payment_failed`
3. Copy the signing secret to credentials

### 7. Configure Mailers

Update `app/mailers/application_mailer.rb`:

```ruby
class ApplicationMailer < ActionMailer::Base
  default from: 'billing@nubbe.net'
  layout 'mailer'
end
```

---

## User Flows

### 1. Onboarding (New Academy)

Start: `https://www.nubbe.net/onboarding/start`

**Steps:**
1. Step 1: Academy name + subdomain
2. Step 2: Select sport (soccer, basketball, volleyball, rugby)
3. Step 3: Choose plan (Free, Starter, Pro)
   - Free plan → Skip to Step 4
   - Paid plans → Stripe checkout for payment method
4. Step 4: First user credentials
5. Step 5: Review and confirm
6. Academy created, auto-logged in

**Key Files:**
- Controller: `app/controllers/onboarding/wizard_controller.rb`
- Views: `app/views/onboarding/wizard/step_*.html.erb`
- Service: `app/services/onboarding/create_academy_service.rb`

### 2. Billing Management

URL: `https://{academy}.nubbe.net/academy/billing`

**Features:**
- View current plan
- Trial countdown banner (if trialing)
- Plan comparison and upgrade
- Stripe Customer Portal link
- Cancel subscription

**Key Files:**
- Controller: `app/controllers/academy/billing_controller.rb`
- View: `app/views/academy/billing/show.html.erb`

### 3. Feature Gating

Feature access is controlled by `Features::GatePolicy`:

```ruby
# In views or controllers
gate = Features::GatePolicy.new(current_user, academy)
gate.can_access?(:tournaments)  # => true if Pro plan
gate.feature_limit(:max_players) # => 25 for Free, 100 for Starter, unlimited for Pro
```

**Feature Mapping** (in `app/policies/features/gate_policy.rb`):
- Free: Dashboard, players, announcements, attendance
- Starter: Free + practice sessions, training plans, teams, coaching
- Pro: Starter + tournaments, cups, financials, advanced analytics

### 4. Superadmin Dashboard

URL: `https://admin.nubbe.net/admin/billing`

**Views:**
1. **Dashboard** (`/admin/billing`)
   - Total MRR & ARR
   - Active subscriptions count
   - Trial expiring soon alerts
   - Recent signups
   - Plan distribution

2. **Subscriptions** (`/admin/billing/subscriptions`)
   - Filter by status, plan, search
   - View all subscriptions
   - MRR per subscription
   - Renewal dates

3. **Analytics** (`/admin/billing/analytics`)
   - MRR trend (12 months)
   - Churn analysis by plan
   - LTV (Lifetime Value)
   - Acquisition funnel

**Key Files:**
- Controller: `app/controllers/admin/billing_dashboard_controller.rb`
- Views: `app/views/admin/billing_dashboard/*`

---

## Stripe Webhook Handling

Webhooks are processed by `StripeEvent` and routed to background jobs:

**Handled Events:**

1. `customer.subscription.updated` → Update subscription status, trial dates
2. `customer.subscription.deleted` → Mark as canceled, send notification
3. `invoice.payment_succeeded` → Update status to active, send receipt
4. `invoice.payment_failed` → Mark as past_due, send retry notice

**Job Files:**
- `app/jobs/stripe/webhooks.rb`

**Testing Webhooks Locally:**

```bash
stripe listen --forward-to localhost:3000/stripe/webhooks
stripe trigger customer.subscription.updated
```

---

## Database Schema

### Plans Table

```ruby
t.enum :tier                # free, starter, pro
t.string :name              # "Free", "Starter", "Pro"
t.text :description
t.integer :price_cents      # 4999 = $49.99
t.integer :monthly_cost_cents
t.integer :trial_days       # 14
t.text :features            # Comma-separated features
t.boolean :visible          # Show in pricing
t.string :stripe_product_id
t.string :stripe_price_id
```

### Subscriptions Table

```ruby
t.references :academy       # Tenant
t.references :plan          # Which plan
t.enum :status              # active, past_due, canceled, paused
t.enum :billing_cycle       # monthly, annual
t.datetime :current_period_start
t.datetime :current_period_end
t.datetime :trial_ends_at   # When trial expires (null = no trial)
t.string :stripe_subscription_id  # Stripe sub ID
t.string :stripe_customer_id      # Stripe customer
t.datetime :canceled_at
t.text :cancellation_reason
```

---

## Key Methods

### Subscription Model

```ruby
subscription.trialing?                    # Is currently in trial
subscription.trial_expiring_soon?(3)       # Expires in 3 days?
subscription.trial_days_remaining          # Days left in trial
subscription.mrr                           # Monthly recurring revenue
subscription.stripe_checkout_session_params # For upgrade flow
```

### Academy Model

```ruby
academy.subscription    # Get the subscription
academy.plan           # Through subscription
academy.owner          # First owner member
```

### Features::GatePolicy

```ruby
gate = Features::GatePolicy.new(user, academy)
gate.can_access?(:tournaments)      # Feature available?
gate.feature_limit(:max_players)    # Limit for feature
gate.limit_exceeded?(:max_teams, 2) # Count exceeded limit?
gate.available_features             # Array of available features
```

---

## Testing

### Test Onboarding Flow

```bash
cd /Users/omolivera/Webapps/superonce
rails server
# Visit https://www.nubbe.net:3000/onboarding/start
```

### Test Stripe Webhooks

```bash
stripe listen --forward-to localhost:3000/stripe/webhooks
# In another terminal:
stripe trigger customer.subscription.updated
```

### Test Feature Gating

```ruby
# In rails console
academy = Academy.first
gate = Features::GatePolicy.new(current_user, academy)
gate.can_access?(:tournaments)  # Should be false for free plan
```

---

## Email Templates

**SubscriptionMailer** sends:

1. `trial_expiring_soon` - 3 days before trial ends
2. `trial_expired` - When trial ends
3. `invoice_paid` - Payment received
4. `invoice_failed` - Payment declined
5. `subscription_canceled` - When subscription canceled
6. `plan_upgraded` - After plan change
7. `plan_downgraded` - After downgrade

Templates are in `app/views/subscription_mailer/`

---

## Common Tasks

### Add a Feature to a Plan

```ruby
Plan.find_by(tier: 'pro').update(
  features: "...existing..., new_feature"
)
```

### Check Feature Access in Views

```erb
<% if feature_available?(:tournaments) %>
  <a href="/club/tournaments">Tournaments</a>
<% else %>
  <span class="locked">Upgrade to Pro</span>
<% end %>
```

### Create Trial Expiry Background Job

```ruby
# config/recurring.yml
trial_expiry_check:
  class: TrialExpiryCheckJob
  every: 1 day
```

```ruby
# app/jobs/trial_expiry_check_job.rb
class TrialExpiryCheckJob < ApplicationJob
  def perform
    Subscription.expiring_soon(3).each do |sub|
      SubscriptionMailer.trial_expiring_soon(sub.academy, 3).deliver_later
    end
  end
end
```

### View MRR Metrics

```ruby
# In rails console
Subscription.active_subscriptions.joins(:plan).sum("plans.price_cents") / 100.0
# => 12345.67 (total MRR in dollars)
```

---

## Troubleshooting

**Issue:** Webhook not being called
- Check Stripe signing secret in credentials
- Verify webhook endpoint URL is correct
- Use `stripe listen` to test locally

**Issue:** Trial not expiring
- Check `trial_ends_at` is set on subscription
- Ensure recurring job is running

**Issue:** Feature gate not working
- Verify `subscription` exists for academy
- Check `plan.features` includes the feature name
- Ensure `Feature::GatePolicy` is being used

**Issue:** Stripe checkout fails
- Verify `stripe_price_id` is set on plan
- Check Stripe API key is correct
- Verify product exists in Stripe Dashboard

---

## Next Steps

1. **Set up Live Stripe Account** - Switch from test to live keys
2. **Configure Marketing Site** - Update pricing page to match plans
3. **Add Trial Expiry Job** - Send emails before trial ends
4. **Implement Analytics** - Track signup funnel conversion
5. **Add Dunning** - Automatic retry logic for failed payments
6. **Team Billing** - Allow multiple users to manage billing
7. **Usage-Based Pricing** - Charge per player or feature usage

---

## Files Created

**Models:**
- `app/models/plan.rb`
- `app/models/subscription.rb`

**Controllers:**
- `app/controllers/onboarding/wizard_controller.rb`
- `app/controllers/academy/billing_controller.rb`
- `app/controllers/admin/billing_dashboard_controller.rb`
- `app/controllers/stripe/webhooks_controller.rb`

**Services:**
- `app/services/onboarding/create_academy_service.rb`

**Forms:**
- `app/forms/onboarding/forms.rb`

**Policies:**
- `app/policies/features/gate_policy.rb`

**Jobs:**
- `app/jobs/stripe/webhooks.rb`

**Mailers:**
- `app/mailers/subscription_mailer.rb`

**Views:**
- Onboarding: 6 views (start + steps 1-5)
- Billing: `app/views/academy/billing/show.html.erb`
- Admin: Billing dashboard + subscriptions list

**Migrations:**
- `db/migrate/2024_04_22_000001_create_plans.rb`
- `db/migrate/2024_04_22_000002_create_subscriptions.rb`

**Seeds:**
- `db/seeds/plans.rb`

---

## Support

For questions or issues, contact the development team.
