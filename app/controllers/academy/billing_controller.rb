module Academy
  class BillingController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_billing_access!
    before_action :set_academy
    before_action :set_subscription

    # GET /academy/billing
    # Billing overview and subscription management
    def show
    end

    # POST /academy/billing/checkout
    # Initiate Stripe checkout for plan upgrade
    def checkout
      new_plan = Plan.find(params[:plan_id])

      unless @subscription.plan_id != new_plan.id
        redirect_to academy_billing_path, alert: "You're already on this plan"
        return
      end

      session_params = {
        customer: @subscription.stripe_customer_id,
        line_items: [{
          price: new_plan.stripe_price_id,
          quantity: 1
        }],
        mode: 'subscription',
        success_url: academy_billing_success_url,
        cancel_url: academy_billing_path
      }

      checkout_session = Stripe::Checkout::Session.create(session_params)
      redirect_to checkout_session.url, allow_other_host: true
    end

    # GET /academy/billing/success
    # Handle successful upgrade
    def checkout_success
      @message = "Plan upgraded successfully!"
      @subscription.reload
    end

    # POST /academy/billing/portal
    # Redirect to Stripe Customer Portal
    def customer_portal
      unless @subscription.stripe_customer_id
        redirect_to academy_billing_path, alert: "Unable to access billing portal"
        return
      end

      session = Stripe::BillingPortal::Session.create(
        customer: @subscription.stripe_customer_id,
        return_url: academy_billing_url
      )

      redirect_to session.url, allow_other_host: true
    end

    # POST /academy/billing/cancel
    # Cancel subscription
    def cancel
      if @subscription.stripe_subscription_id
        Stripe::Subscription.delete(@subscription.stripe_subscription_id)
      end

      @subscription.update(
        status: :canceled,
        canceled_at: Time.current,
        cancellation_reason: params[:reason]
      )

      redirect_to academy_billing_path, notice: "Subscription canceled"
    end

    # POST /academy/billing/reactivate
    # Reactivate canceled subscription
    def reactivate
      if @subscription.stripe_subscription_id
        Stripe::Subscription.update(
          @subscription.stripe_subscription_id,
          pause_collection: nil
        )
      end

      @subscription.update(status: :active, canceled_at: nil)

      redirect_to academy_billing_path, notice: "Subscription reactivated"
    end

    private

    def authorize_billing_access!
      academy = Current.academy
      authorize academy, :manage_billing?
    end

    def set_academy
      @academy = Current.academy
    end

    def set_subscription
      @subscription = @academy.subscription
      @plans = Plan.visible
    end
  end
end
