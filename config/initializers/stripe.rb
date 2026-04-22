# Stripe configuration
Stripe.api_key = Rails.application.credentials.dig(:stripe, :secret_key)

StripeEvent.signing_secret = Rails.application.credentials.dig(:stripe, :webhook_secret)

StripeEvent.configure do |events|
  events.subscribe 'customer.subscription.updated' do |event|
    Stripe::Webhooks::SubscriptionUpdatedJob.perform_later(event.data.object)
  end

  events.subscribe 'customer.subscription.deleted' do |event|
    Stripe::Webhooks::SubscriptionDeletedJob.perform_later(event.data.object)
  end

  events.subscribe 'invoice.payment_succeeded' do |event|
    Stripe::Webhooks::InvoicePaidJob.perform_later(event.data.object)
  end

  events.subscribe 'invoice.payment_failed' do |event|
    Stripe::Webhooks::InvoiceFailedJob.perform_later(event.data.object)
  end
end
