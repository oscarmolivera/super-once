module FeaturesHelper
  # Check if feature is available for current academy
  def feature_available?(feature_name)
    gate_policy.can_access?(feature_name)
  end

  # Show a feature gate message if not available
  def feature_locked?(feature_name)
    !feature_available?(feature_name)
  end

  # Get all available features
  def available_features
    gate_policy.available_features
  end

  # Check if user is on trial
  def on_trial?
    current_academy&.subscription&.trialing? || false
  end

  # Get trial days remaining
  def trial_days_remaining
    return 0 unless current_academy&.subscription

    current_academy.subscription.trial_days_remaining
  end

  # Check if trial is expiring soon
  def trial_expiring_soon?
    gate_policy.trial_expiring_soon?
  end

  # Get current plan name
  def current_plan_name
    return "Superadmin" if current_user&.superadmin?
    return "Free" unless current_academy&.subscription

    current_academy.subscription.plan.name
  end

  # Get the feature limit
  def feature_limit(feature_name)
    gate_policy.feature_limit(feature_name)
  end

  private

  def gate_policy
    @gate_policy ||= Features::GatePolicy.new(current_user, current_academy)
  end

  def current_academy
    Current.academy
  end
end
