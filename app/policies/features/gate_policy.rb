module Features
  class GatePolicy
    # Plan features mapping
    PLAN_FEATURES = {
      'free' => %w[
        dashboard
        basic_players
        announcements
        attendance_tracking
      ],
      'starter' => %w[
        dashboard
        unlimited_players
        announcements
        attendance_tracking
        practice_sessions
        training_plans
        team_management
        categories
        coach_assignments
      ],
      'pro' => %w[
        dashboard
        unlimited_players
        announcements
        attendance_tracking
        practice_sessions
        training_plans
        team_management
        categories
        coach_assignments
        tournaments
        cups
        financial_reports
        salary_management
        inventory
        advanced_analytics
      ]
    }.freeze

    def initialize(user, academy = nil)
      @user = user
      @academy = academy || Current.academy
    end

    # Check if a feature is available for the academy's plan
    def can_access?(feature_name)
      return true if @user&.superadmin?
      return false unless @academy&.subscription

      plan_tier = @academy.subscription.plan.tier
      available_features = PLAN_FEATURES[plan_tier] || []

      available_features.include?(feature_name.to_s)
    end

    # List all available features for the academy's plan
    def available_features
      return PLAN_FEATURES['pro'] if @user&.superadmin?
      return [] unless @academy&.subscription

      plan_tier = @academy.subscription.plan.tier
      PLAN_FEATURES[plan_tier] || []
    end

    # Get the feature limit for a given feature (e.g., max players for free plan)
    def feature_limit(feature_name)
      plan_tier = @academy.subscription&.plan&.tier || 'free'

      case feature_name.to_s
      when 'max_players'
        case plan_tier
        when 'free' then 25
        when 'starter' then 100
        when 'pro' then Float::INFINITY
        else 25
        end
      when 'max_coaches'
        case plan_tier
        when 'free' then 1
        when 'starter' then 5
        when 'pro' then Float::INFINITY
        else 1
        end
      when 'max_teams'
        case plan_tier
        when 'free' then 1
        when 'starter' then 10
        when 'pro' then Float::INFINITY
        else 1
        end
      else
        Float::INFINITY
      end
    end

    # Check if a limit is exceeded
    def limit_exceeded?(feature_name, current_count)
      limit = feature_limit(feature_name)
      current_count >= limit
    end

    # Trial expiry notification
    def trial_expiring_soon?
      return false if @user&.superadmin?
      return false unless @academy&.subscription

      @academy.subscription.trial_expiring_soon?(3)
    end

    def trial_expired?
      return false if @user&.superadmin?
      return false unless @academy&.subscription

      !@academy.subscription.trialing? && @academy.subscription.plan.trial_days.positive?
    end
  end
end
