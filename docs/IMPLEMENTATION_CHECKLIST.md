# SaaS Billing Implementation Checklist

## ✅ Completed Components

### Core Models & Database
- [x] Plan model with free/starter/pro tiers
- [x] Subscription model with trial tracking
- [x] Database migrations for plans and subscriptions
- [x] Academy.subscription and Academy.plan associations

### Onboarding Flow
- [x] 5-step wizard controller
- [x] Form validation classes for each step
- [x] Step 1: Academy name + subdomain validation
- [x] Step 2: Sport selection
- [x] Step 3: Plan selection
- [x] Step 3: Stripe checkout for paid plans
- [x] Step 4: First user account creation
- [x] Step 5: Review and confirmation
- [x] CreateAcademyService to orchestrate creation
- [x] Automatic Stripe customer creation
- [x] Automatic membership creation as owner

### Views
- [x] Onboarding layout with progress bar
- [x] Step 1 view (academy details)
- [x] Step 2 view (sport selection)
- [x] Step 3 view (plan selection)
- [x] Step 4 view (user details)
- [x] Step 5 view (review)
- [x] Start/landing page
- [x] Academy billing portal view
- [x] Superadmin billing dashboard
- [x] Subscriptions list with filters

### Stripe Integration
- [x] Stripe gem added to Gemfile
- [x] stripe_event gem for webhook handling
- [x] Stripe initializer with webhook configuration
- [x] Stripe webhooks controller
- [x] Webhook jobs for:
  - [x] customer.subscription.updated
  - [x] customer.subscription.deleted
  - [x] invoice.payment_succeeded
  - [x] invoice.payment_failed

### Feature Gating
- [x] Features::GatePolicy class
- [x] Feature mappings per plan tier
- [x] Feature limit definitions
- [x] FeaturesHelper for views
- [x] Pundit policy integration
- [x] Trial tracking methods

### Billing Portal
- [x] Academy billing controller
- [x] Billing show view
- [x] Plan upgrade flow
- [x] Stripe Customer Portal link
- [x] Cancel subscription with reason
- [x] Reactivate canceled plan
- [x] Trial countdown banner

### Superadmin Dashboard
- [x] Billing dashboard controller
- [x] MRR and ARR calculations
- [x] Active subscriptions metrics
- [x] Churn rate calculation
- [x] Plan distribution analysis
- [x] Expiring trials alerts
- [x] Recent signups list
- [x] Subscriptions list with filters
- [x] Analytics view with trends
- [x] MRR trend calculation
- [x] Churn analysis by plan
- [x] LTV (Lifetime Value) analysis
- [x] Acquisition funnel metrics

### Email Notifications
- [x] SubscriptionMailer class
- [x] trial_expiring_soon template
- [x] trial_expired template
- [x] invoice_paid template
- [x] invoice_failed template
- [x] subscription_canceled template
- [x] plan_upgraded template
- [x] plan_downgraded template

### Routes
- [x] Onboarding routes (www subdomain)
- [x] Academy billing routes (tenant subdomain)
- [x] Admin billing routes (admin subdomain)
- [x] Stripe webhook route

### Authorization
- [x] Pundit policy methods for billing
- [x] Feature access checks
- [x] Trial expiry checks

### Seeds & Documentation
- [x] Plan seeding script
- [x] Comprehensive SAAS_BILLING_GUIDE.md
- [x] Implementation notes

---

## 🔄 Configuration Steps Required

### Stripe Setup
- [ ] Get Stripe API keys (test & live)
- [ ] Create 3 products in Stripe (Free, Starter, Pro)
- [ ] Get product IDs and price IDs
- [ ] Add to Rails credentials:
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
- [ ] Configure webhook endpoint in Stripe Dashboard
- [ ] Test webhooks locally with stripe listen

### Database
- [ ] Run migrations: `rails db:migrate`
- [ ] Seed plans: `rails db:seed:plans`

### Email
- [ ] Verify sender email address is configured
- [ ] Test email delivery in development
- [ ] Configure production email service

### Testing
- [ ] Test onboarding flow end-to-end
- [ ] Test stripe webhook handling
- [ ] Test feature gating per plan
- [ ] Test trial expiry notifications
- [ ] Test plan upgrades/downgrades
- [ ] Test admin dashboard metrics

---

## 📋 Testing Checklist

### Onboarding Flow
- [ ] Navigate through all 5 steps without errors
- [ ] Slug validation works (no duplicates, reserved words)
- [ ] Free plan skips checkout and goes to step 4
- [ ] Paid plans show Stripe checkout
- [ ] Academy created with correct slug and name
- [ ] First user created as owner
- [ ] Subscription created with correct plan
- [ ] Automatic redirect to academy dashboard

### Billing Portal
- [ ] Academy owners can access /academy/billing
- [ ] Trial countdown banner shows for trial subscriptions
- [ ] Plan comparison displays features correctly
- [ ] Upgrade button initiates Stripe checkout
- [ ] Cancel subscription shows reason modal
- [ ] Reactivate works on canceled subscriptions
- [ ] Customer Portal link works

### Feature Gating
- [ ] Free plan blocks tournaments/cups
- [ ] Starter plan allows practice sessions
- [ ] Pro plan allows all features
- [ ] Superadmin can access all features
- [ ] Feature limits enforce correctly
- [ ] Helper methods return correct values

### Admin Dashboard
- [ ] /admin/billing loads without errors
- [ ] MRR calculation is accurate
- [ ] Active subscription count is correct
- [ ] Churn rate calculation is correct
- [ ] Expiring trials list shows correct academies
- [ ] Recent signups list displays correctly
- [ ] Subscription filter works by status/plan/search
- [ ] Analytics view loads and calculates trends

### Stripe Integration
- [ ] Webhook events are received
- [ ] Subscription status updates on webhook
- [ ] Invoice payments are recorded
- [ ] Failed payments mark subscription past_due

### Email
- [ ] Trial expiry emails send
- [ ] Invoice paid emails send
- [ ] Payment failed emails send
- [ ] Subscription canceled emails send

---

## 🚀 Deployment Steps

1. [ ] Deploy code to staging
2. [ ] Run migrations on staging
3. [ ] Seed plans on staging
4. [ ] Test full onboarding flow on staging
5. [ ] Configure Stripe webhook for staging
6. [ ] Run full test suite
7. [ ] Deploy to production
8. [ ] Run migrations on production
9. [ ] Seed plans on production
10. [ ] Update Stripe webhook to production domain
11. [ ] Monitor error logs for issues
12. [ ] Verify a few test academies can onboard

---

## 📊 Post-Launch Monitoring

### Metrics to Track
- [ ] Onboarding completion rate
- [ ] Plan selection distribution
- [ ] Trial conversion rate
- [ ] Churn rate by plan
- [ ] MRR growth month-over-month
- [ ] Payment success rate

### Common Issues to Watch For
- [ ] Failed Stripe API calls
- [ ] Webhook delivery failures
- [ ] Email delivery issues
- [ ] Trial expiry notifications not sending
- [ ] Feature gates blocking legitimate access

---

## 🎯 Future Enhancements

### Phase 7 Potential Features
- [ ] Annual billing option
- [ ] Coupon/discount code system
- [ ] Team billing (multiple users manage subscription)
- [ ] Usage-based add-ons (extra players, teams, etc.)
- [ ] Dunning/automatic retry for failed payments
- [ ] Custom branding per academy
- [ ] API key generation for integrations
- [ ] Webhook subscriptions for third-party apps
- [ ] White-label partner plans
- [ ] Volume discounts for enterprise

---

## 📞 Support Resources

- Stripe Documentation: https://stripe.com/docs
- Rails Pundit: https://github.com/varvet/pundit
- Full Implementation Guide: `/SAAS_BILLING_GUIDE.md`
- Session Notes: `/memories/session/saas_implementation.md`

---

Generated: 2024-04-22
Status: Ready for Configuration & Testing
