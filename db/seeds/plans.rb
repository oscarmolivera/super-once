# Seed Plans
# Run with: rails db:seed

puts "Creating plan tiers..."

free_plan = Plan.create(tier: 'free') do |plan|
  plan.name = 'Free'
  plan.description = 'Perfect for getting started'
  plan.price_cents = 0
  plan.monthly_cost_cents = 0
  plan.trial_days = 0
  plan.visible = true
  plan.features = "Dashboard, Basic player management, Announcements, Attendance tracking"
  plan.stripe_product_id = ENV['STRIPE_PRODUCT_FREE'] # Set in credentials
  plan.stripe_price_id = ENV['STRIPE_PRICE_FREE']
end
puts "✓ Free plan created"

starter_plan = Plan.create(tier: 'starter') do |plan|
  plan.name = 'Starter'
  plan.description = 'Great for growing academies'
  plan.price_cents = 4999
  plan.monthly_cost_cents = 4999
  plan.trial_days = 14
  plan.visible = true
  plan.features = "Everything in Free, Unlimited players, Practice sessions, Training plans, Team management, Coaching assignments, Advanced categories"
  plan.stripe_product_id = ENV['STRIPE_PRODUCT_STARTER']
  plan.stripe_price_id = ENV['STRIPE_PRICE_STARTER']
end
puts "✓ Starter plan created ($49.99/month)"

pro_plan = Plan.create(tier: 'pro') do |plan|
  plan.name = 'Pro'
  plan.description = 'For advanced sports management'
  plan.price_cents = 9999
  plan.monthly_cost_cents = 9999
  plan.trial_days = 14
  plan.visible = true
  plan.features = "Everything in Starter, Tournaments, Cups, Financial reports, Salary management, Inventory tracking, Advanced analytics, API access"
  plan.stripe_product_id = ENV['STRIPE_PRODUCT_PRO']
  plan.stripe_price_id = ENV['STRIPE_PRICE_PRO']
end
puts "✓ Pro plan created ($99.99/month)"

puts "\n✅ Plans seeded successfully!"
puts "\nNote: Set Stripe product and price IDs in credentials:"
puts "  STRIPE_PRODUCT_FREE, STRIPE_PRICE_FREE"
puts "  STRIPE_PRODUCT_STARTER, STRIPE_PRICE_STARTER"
puts "  STRIPE_PRODUCT_PRO, STRIPE_PRICE_PRO"
