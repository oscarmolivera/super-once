# SaaS Billing - Quick Reference Card

## Key URLs

| Environment     | URL                                                   |
| --------------- | ----------------------------------------------------- |
| Onboarding      | `https://www.nubbe.net/onboarding/start`              |
| Billing         | `https://{academy}.nubbe.net/academy/billing`         |
| Admin Dashboard | `https://admin.nubbe.net/admin/billing`               |
| Subscriptions   | `https://admin.nubbe.net/admin/billing/subscriptions` |
| Analytics       | `https://admin.nubbe.net/admin/billing/analytics`     |

## Feature Access Pattern

```ruby
# In controllers
gate = Features::GatePolicy.new(current_user, Current.academy)
gate.can_access?(:tournaments)  # => true/false

# In views with helper
<% if feature_available?(:tournaments) %>
  <%= link_to "Tournaments", club_tournaments_path %>
<% else %>
  <span class="locked">Pro plan required</span>
<% end %>

# Check limits
gate.feature_limit(:max_players)        # => 25 (free), 100 (starter), ∞ (pro)
gate.limit_exceeded?(:max_players, 30)  # => true (free) / false (starter/pro)
```

## Plan Tiers

| Feature     | Free | Starter   | Pro       |
| ----------- | ---- | --------- | --------- |
| Price       | Free | $49.99/mo | $99.99/mo |
| Trial       | None | 14 days   | 14 days   |
| Players     | 25   | 100       | Unlimited |
| Teams       | 1    | 10        | Unlimited |
| Coaches     | 1    | 5         | Unlimited |
| Tournaments | ❌    | ❌         | ✅         |
| Financials  | ❌    | ❌         | ✅         |

## Subscription States

```ruby
subscription.status           # active, past_due, canceled, paused
subscription.trialing?        # Currently in trial?
subscription.trial_days_remaining  # Days left in trial
subscription.current_period_end    # Next billing date
subscription.mrr              # Monthly recurring revenue in $
```

## Mailers

```ruby
# Send emails
SubscriptionMailer.trial_expiring_soon(academy, 3).deliver_later
SubscriptionMailer.invoice_paid(academy, stripe_invoice).deliver_later
SubscriptionMailer.plan_upgraded(academy, old_plan, new_plan).deliver_later
```

## Database Queries

```ruby
# Find all active subscriptions
Subscription.active_subscriptions

# Find all on trial
Subscription.on_trial

# Calculate total MRR
Subscription.active_subscriptions.joins(:plan).sum("plans.price_cents") / 100.0

# Find expiring trials
Subscription.expiring_soon(3)  # Expiring in 3 days

# By plan
Subscription.joins(:plan).where("plans.tier = ?", 'pro')
```

## Common Tasks

### Check Feature Access in Controller

```ruby
authorize Current.academy, :manage_billing?  # Raises if not authorized
```

### Get Current Plan Name

```ruby
current_academy.subscription.plan.name  # => "Starter"
```

### Check Trial Status

```ruby
on_trial?                    # Helper method
trial_days_remaining         # Helper method
trial_expiring_soon?         # Helper method (3 days default)
```

### Create Subscription Manually

```ruby
academy.create_subscription(
  plan: Plan.find_by(tier: 'starter'),
  status: :active,
  billing_cycle: :monthly,
  current_period_start: Time.current,
  current_period_end: 1.month.from_now,
  trial_ends_at: 14.days.from_now,
  stripe_customer_id: 'cus_xxx'
)
```

## Stripe Testing

### Test Webhook Locally

```bash
# Terminal 1: Start listener
stripe listen --forward-to localhost:3000/stripe/webhooks

# Terminal 2: Trigger event
stripe trigger customer.subscription.updated

# View logs
tail -f log/development.log
```

### Test Payment Method

Use Stripe test card: `4242 4242 4242 4242`

## File Locations

| Purpose     | File                                                               |
| ----------- | ------------------------------------------------------------------ |
| Models      | `app/models/plan.rb`, `app/models/subscription.rb`                 |
| Controllers | `app/controllers/{onboarding,academy,admin,stripe}/*`              |
| Policies    | `app/policies/features/gate_policy.rb`                             |
| Helpers     | `app/helpers/features_helper.rb`                                   |
| Jobs        | `app/jobs/stripe/webhooks.rb`                                      |
| Mailers     | `app/mailers/subscription_mailer.rb`                               |
| Views       | `app/views/{onboarding,academy/billing,admin/billing_dashboard}/*` |
| Routes      | `config/routes.rb`                                                 |

## Credentials Setup

```bash
EDITOR=nano rails credentials:edit
```

Add:
```yaml
stripe:
  secret_key: sk_test_xxx
  webhook_secret: whsec_xxx
  product_free: prod_xxx
  price_free: price_xxx
  product_starter: prod_xxx
  price_starter: price_xxx
  product_pro: prod_xxx
  price_pro: price_xxx
```

## Debugging

### Webhook not working?
1. Check `StripeEvent.configure` in `config/initializers/stripe.rb`
2. Verify webhook signature secret in credentials
3. Check `ActiveJob` queue is processing (`bundle exec solid_queue start`)

### Feature access not working?
1. Verify subscription exists: `academy.subscription`
2. Check plan: `academy.subscription.plan.tier`
3. Test policy: `Features::GatePolicy.new(user, academy).can_access?(:feature)`

### Email not sending?
1. Check ActionMailer config
2. Verify `deliver_later` is queued
3. Run jobs: `bundle exec solid_queue start`

## Performance Notes

- Feature gates are instant (no DB calls)
- MRR calculations done at request time (cache if needed)
- Webhook jobs run async via Solid Queue

## Security

- Stripe webhook signature verified
- Billing actions require `manage_billing?` policy
- Trial expiry is enforced server-side
- Features checked on every request (no client-side gating)

---

**Last Updated:** 2024-04-22
**Version:** Phase 6 - Complete Implementation
