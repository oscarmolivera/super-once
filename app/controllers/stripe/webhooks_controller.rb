module Stripe
  class WebhooksController < ApplicationController
    skip_before_action :authenticate_user!
    skip_before_action :verify_authenticity_token

    def create
      payload = request.body.read
      event = nil

      begin
        event = StripeEvent.parse_event(payload, request.headers['Stripe-Signature'])
      rescue StandardError => e
        Rails.logger.error("Stripe webhook parse error: #{e.message}")
        head :bad_request and return
      end

      StripeEvent.dispatch(event)

      head :no_content
    end
  end
end
