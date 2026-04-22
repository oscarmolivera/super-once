module Onboarding
  class CreateAcademyService
    Result = Struct.new(:success?, :academy, :user, :errors)

    def initialize(onboarding_data, current_user = nil)
      @onboarding_data = onboarding_data || {}
      @current_user = current_user
      @errors = []
    end

    def call
      ActiveRecord::Base.transaction do
        # Create or find first user
        user = create_user
        return Result.new(false, nil, nil, @errors) if @errors.any?

        # Create academy
        academy = create_academy
        return Result.new(false, nil, user, @errors) if @errors.any?

        # Create membership (user as owner)
        create_membership(academy, user)
        return Result.new(false, academy, user, @errors) if @errors.any?

        # Create subscription and trial
        create_subscription(academy)
        return Result.new(false, academy, user, @errors) if @errors.any?

        Result.new(true, academy, user, @errors)
      rescue StandardError => e
        @errors << e.message
        Result.new(false, nil, nil, @errors)
      end
    end

    private

    def create_user
      if @current_user
        @current_user
      else
        user_data = {
          email_address: @onboarding_data[:email],
          password: @onboarding_data[:password],
          password_confirmation: @onboarding_data[:password]
        }

        user = User.new(user_data)
        unless user.save
          @errors.concat(user.errors.full_messages)
          return nil
        end
        user
      end
    end

    def create_academy
      academy_data = {
        name: @onboarding_data[:academy_name],
        slug: @onboarding_data[:slug],
        status: :active
      }

      academy = Academy.new(academy_data)
      unless academy.save
        @errors.concat(academy.errors.full_messages)
        return nil
      end
      academy
    end

    def create_membership(academy, user)
      membership = academy.memberships.new(user: user, role: :owner)
      unless membership.save
        @errors.concat(membership.errors.full_messages)
        return nil
      end
      membership
    end

    def create_subscription(academy)
      plan = Plan.find(@onboarding_data[:plan_id])

      # Create Stripe customer
      stripe_customer = Stripe::Customer.create(
        email: academy.owner.email_address,
        metadata: {
          academy_id: academy.id,
          academy_name: academy.name
        }
      )

      # Determine trial end date
      trial_ends_at = plan.free? ? nil : plan.trial_days.days.from_now

      subscription = academy.build_subscription(
        plan: plan,
        status: :active,
        billing_cycle: :monthly,
        current_period_start: Time.current,
        current_period_end: 1.month.from_now,
        trial_ends_at: trial_ends_at,
        stripe_customer_id: stripe_customer.id
      )

      unless subscription.save
        @errors.concat(subscription.errors.full_messages)
        return nil
      end

      subscription
    end
  end
end
