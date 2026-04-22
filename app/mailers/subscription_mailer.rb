class SubscriptionMailer < ApplicationMailer
  default from: 'billing@nubbe.net'

  # Trial expiring soon
  def trial_expiring_soon(academy, days_remaining = 3)
    @academy = academy
    @days_remaining = days_remaining
    @subscription = academy.subscription
    @plan = @subscription.plan

    mail(
      to: academy.owner.email_address,
      subject: "Your #{@plan.name} trial expires in #{days_remaining} days"
    )
  end

  # Trial expired
  def trial_expired(academy)
    @academy = academy
    @subscription = academy.subscription
    @plan = @subscription.plan

    mail(
      to: academy.owner.email_address,
      subject: "Your free trial has expired - Upgrade now"
    )
  end

  # Invoice paid
  def invoice_paid(academy, invoice_data)
    @academy = academy
    @amount = (invoice_data['amount_paid'] / 100.0)
    @date = Time.at(invoice_data['date']).strftime('%B %d, %Y')
    @subscription = academy.subscription

    mail(
      to: academy.owner.email_address,
      subject: "Payment received for SuperOnce - $#{@amount}"
    )
  end

  # Invoice failed
  def invoice_failed(academy, invoice_data)
    @academy = academy
    @amount = (invoice_data['amount_due'] / 100.0)
    @subscription = academy.subscription
    @retry_date = Time.at(invoice_data['next_payment_attempt']).strftime('%B %d, %Y') if invoice_data['next_payment_attempt']

    mail(
      to: academy.owner.email_address,
      subject: "Payment failed for SuperOnce subscription"
    )
  end

  # Subscription canceled
  def subscription_canceled(academy)
    @academy = academy
    @plan = academy.subscription.plan

    mail(
      to: academy.owner.email_address,
      subject: "Your SuperOnce subscription has been canceled"
    )
  end

  # Plan upgraded
  def plan_upgraded(academy, old_plan, new_plan)
    @academy = academy
    @old_plan = old_plan
    @new_plan = new_plan

    mail(
      to: academy.owner.email_address,
      subject: "Welcome to the #{new_plan.name} plan!"
    )
  end

  # Plan downgraded
  def plan_downgraded(academy, old_plan, new_plan)
    @academy = academy
    @old_plan = old_plan
    @new_plan = new_plan

    mail(
      to: academy.owner.email_address,
      subject: "You've downgraded to the #{new_plan.name} plan"
    )
  end
end
