# SaaS Billing - Environment Setup Guide

## Prerequisites

- Ruby 3.2+
- Rails 8.1+
- PostgreSQL 14+
- Stripe account (https://stripe.com)

## Step 1: Install Dependencies

```bash
cd /Users/omolivera/Webapps/superonce
bundle install
```

This installs:
- `stripe` - Stripe payment library
- `stripe_event` - Webhook handler
- `acts_as_tenant` - Multi-tenancy
- `pundit` - Authorization
- Other existing dependencies

## Step 2: Set Up Credentials

Create/edit Rails credentials:

```bash
EDITOR=nano rails credentials:edit
```

**Paste this template and fill in your Stripe keys:**

```yaml
# Stripe Configuration
stripe:
  # API Keys (from https://dashboard.stripe.com/apikeys)
  secret_key: # insert with your secret key

  # Webhook Secret (from https://dashboard.stripe.com/webhooks)
  webhook_secret: whsec_test_secret...  # Replace with your webhook signing secret

  # Product IDs (create in Stripe Dashboard)
  # See Step 4 below for how to get these
  product_free: prod_xxx
  price_free: price_xxx
  product_starter: prod_xxx
  price_starter: price_xxx
  product_pro: prod_xxx
  price_pro: price_xxx

# Email Configuration
mail:
  from: billing@nubbe.net  # Update to your domain
```

**Save:** Press Ctrl+X, then Y, then Enter

## Step 3: Create Stripe Account & Get Keys

### Create Account
1. Go to https://stripe.com
2. Sign up for free account
3. Complete email verification

### Get API Keys
1. Go to https://dashboard.stripe.com/apikeys
2. Use **Test** mode during development
3. Copy **Secret key** (starts with `sk_test_`)
4. Save to credentials as `stripe.secret_key`

### Enable Webhooks
1. Go to https://dashboard.stripe.com/webhooks
2. Click "Add endpoint"
3. **Endpoint URL:** `http://localhost:3000/stripe/webhooks` (local testing)
   - For production: `https://yourdomain.com/stripe/webhooks`
4. **Events to listen:** Select these:
   - `customer.subscription.updated`
   - `customer.subscription.deleted`
   - `invoice.payment_succeeded`
   - `invoice.payment_failed`
5. Click "Create endpoint"
6. Click on endpoint to view **Signing secret**
7. Copy signing secret (starts with `whsec_`)
8. Save to credentials as `stripe.webhook_secret`

## Step 4: Create Stripe Products & Prices

In Stripe Dashboard (https://dashboard.stripe.com):

### Product 1: Free Plan
1. Go to Products → Create Product
2. **Name:** `Free`
3. **Type:** Standard pricing
4. **Pricing:** Leave blank (no charge)
5. **Save**
6. Copy **Product ID** (starts with `prod_`)
7. Save to credentials as `stripe.product_free`
8. **Note:** Free products don't have prices, leave `price_free` empty

### Product 2: Starter Plan
1. Go to Products → Create Product
2. **Name:** `Starter`
3. **Type:** Standard pricing
4. **Pricing model:** Recurring
5. **Price:** $49.99
6. **Billing period:** Monthly
7. **Save**
8. Copy **Product ID** and **Price ID** (from Pricing section)
9. Save to credentials as:
   - `stripe.product_starter: prod_xxx`
   - `stripe.price_starter: price_xxx`

### Product 3: Pro Plan
1. Go to Products → Create Product
2. **Name:** `Pro`
3. **Type:** Standard pricing
4. **Pricing model:** Recurring
5. **Price:** $99.99
6. **Billing period:** Monthly
7. **Save**
8. Copy **Product ID** and **Price ID**
9. Save to credentials as:
   - `stripe.product_pro: prod_xxx`
   - `stripe.price_pro: price_xxx`

## Step 5: Run Database Migrations

```bash
# Create tables for plans and subscriptions
rails db:migrate

# Status check
rails db:migrate:status
```

Should show:
- `CreatePlans` - up
- `CreateSubscriptions` - up

## Step 6: Seed Plans

```bash
# Create the three plan tiers in database
rails db:seed:plans
```

Verify in Rails console:
```bash
rails console

# In console:
Plan.all
Plan.find_by(tier: 'starter').stripe_price_id
```

Should show:
```
Free:     $0
Starter:  $49.99/month
Pro:      $99.99/month
```

## Step 7: Test Stripe Webhooks Locally

Stripe CLI is required for local testing:

### Install Stripe CLI
```bash
# macOS
brew install stripe/stripe-cli/stripe

# Verify installation
stripe version
```

### Forward Webhooks to Local Server

In one terminal:
```bash
# Authenticate with Stripe account
stripe login
# Follow the browser flow to authorize

# Listen for webhooks and forward to local server
stripe listen --forward-to localhost:3000/stripe/webhooks
```

This will output:
```
Ready! Your webhook signing secret is: whsec_test_xxx
```

### Trigger Test Events

In another terminal:
```bash
# Test a webhook event
stripe trigger customer.subscription.updated

# Check Rails logs
tail -f log/development.log
```

Should see webhook processing in logs.

## Step 8: Configure Email (Optional)

For development, use Letter Opener:

```ruby
# config/environments/development.rb
config.action_mailer.delivery_method = :letter_opener
config.action_mailer.default_url_options = { host: 'localhost:3000' }
```

Emails will open in browser automatically.

## Step 9: Start the Application

```bash
# Terminal 1: Main app
./bin/dev

# Terminal 2 (if needed): Stripe webhook listener
stripe listen --forward-to localhost:3000/stripe/webhooks
```

Visit: `http://localhost:3000`

## Step 10: Test Onboarding Flow

1. Open browser: `http://www.localhost:3000/onboarding/start`
2. Create a test academy:
   - Name: "Test Academy"
   - Slug: "test-academy"
   - Sport: "Soccer"
   - Plan: Free (to skip checkout)
   - User: Your test email
3. Should redirect to `http://test-academy.localhost:3000`

## Step 11: Test Stripe Checkout (Optional)

To test paid plan checkout:

1. Use Stripe test card: **4242 4242 4242 4242**
2. Expiry: Any future date
3. CVC: Any 3 digits
4. Payment should succeed
5. Check Stripe Dashboard for test charge

## Troubleshooting

### Stripe key not found
```bash
# Re-edit credentials
EDITOR=nano rails credentials:edit

# Check YAML syntax (no tabs, proper indentation)
```

### Webhook not working
1. Verify `stripe listen` is running
2. Check signing secret in credentials matches output
3. Check Rails logs for errors
4. Verify job queue is running (`bundle exec solid_queue start`)

### Email not sending
1. Check ActionMailer config in development.rb
2. Verify letter_opener gem is installed
3. Check Rails logs for errors

### Database errors
```bash
# Reset database
rails db:drop
rails db:create
rails db:migrate
rails db:seed:plans
```

## Environment Variables (Alternative)

Instead of credentials, can use env vars:

```bash
export STRIPE_SECRET_KEY=sk_test_xxx
export STRIPE_WEBHOOK_SECRET=whsec_xxx
export STRIPE_PRODUCT_FREE=prod_xxx
export STRIPE_PRICE_STARTER=price_xxx
export STRIPE_PRICE_PRO=price_xxx
```

Then update `config/initializers/stripe.rb`:
```ruby
Stripe.api_key = ENV['STRIPE_SECRET_KEY']
StripeEvent.signing_secret = ENV['STRIPE_WEBHOOK_SECRET']
```

## Next Steps

1. ✅ Verify app starts: `./bin/dev`
2. ✅ Test onboarding: `www.localhost:3000/onboarding/start`
3. ✅ Test billing: `{academy}.localhost:3000/academy/billing`
4. ✅ Test admin dashboard: `admin.localhost:3000/admin/billing`
5. 📖 Read [SAAS_BILLING_GUIDE.md](SAAS_BILLING_GUIDE.md) for full documentation

## Quick Reference

| Task             | Command                                                     |
| ---------------- | ----------------------------------------------------------- |
| Edit credentials | `EDITOR=nano rails credentials:edit`                        |
| Run server       | `./bin/dev`                                                 |
| Run migrations   | `rails db:migrate`                                          |
| Seed plans       | `rails db:seed:plans`                                       |
| Console access   | `rails console`                                             |
| Test webhooks    | `stripe listen --forward-to localhost:3000/stripe/webhooks` |
| View logs        | `tail -f log/development.log`                               |

---

**Setup Time:** ~15 minutes
**Date:** 2024-04-22
**Status:** Ready to Go! 🚀
