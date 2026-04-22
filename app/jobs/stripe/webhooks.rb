module Stripe
  module Webhooks
    class SubscriptionUpdatedJob < ApplicationJob
      queue_as :default

      def perform(stripe_subscription_data)
        subscription = Subscription.find_by(stripe_subscription_id: stripe_subscription_data['id'])
        return unless subscription

        # Update subscription status
        status_map = {
          'active' => 'active',
          'past_due' => 'past_due',
          'canceled' => 'canceled',
          'paused' => 'paused'
        }

        subscription.update(
          status: status_map[stripe_subscription_data['status']] || 'active',
          current_period_start: Time.at(stripe_subscription_data['current_period_start']),
          current_period_end: Time.at(stripe_subscription_data['current_period_end']),
          trial_ends_at: stripe_subscription_data['trial_end'] ? Time.at(stripe_subscription_data['trial_end']) : nil
        )
      end
    end

    class SubscriptionDeletedJob < ApplicationJob
      queue_as :default

      def perform(stripe_subscription_data)
        subscription = Subscription.find_by(stripe_subscription_id: stripe_subscription_data['id'])
        return unless subscription

        subscription.update(
          status: :canceled,
          canceled_at: Time.current
        )

        # Notify academy owner of cancellation
        SubscriptionMailer.subscription_canceled(subscription.academy).deliver_later
      end
    end

    class InvoicePaidJob < ApplicationJob
      queue_as :default

      def perform(stripe_invoice_data)
        subscription = Subscription.find_by(stripe_customer_id: stripe_invoice_data['customer'])
        return unless subscription

        # Create invoice record if needed
        # Update subscription status to active if it was past_due
        subscription.update(status: :active) if subscription.past_due?

        SubscriptionMailer.invoice_paid(subscription.academy, stripe_invoice_data).deliver_later
      end
    end

    class InvoiceFailedJob < ApplicationJob
      queue_as :default

      def perform(stripe_invoice_data)
        subscription = Subscription.find_by(stripe_customer_id: stripe_invoice_data['customer'])
        return unless subscription

        subscription.update(status: :past_due)

        SubscriptionMailer.invoice_failed(subscription.academy, stripe_invoice_data).deliver_later
      end
    end
  end
end
