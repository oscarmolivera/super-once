module Admin
  class BillingDashboardController < ApplicationController
    before_action :authenticate_superadmin!

    # GET /admin/billing
    # Superadmin billing overview
    def index
      @page_title = "Billing Dashboard"
      @total_mrr = calculate_total_mrr
      @total_arr = @total_mrr * 12
      @active_subscriptions = Subscription.active_subscriptions.count
      @trial_subscriptions = Subscription.on_trial.count
      @canceled_subscriptions = Subscription.where(status: :canceled).count

      @plan_distribution = calculate_plan_distribution
      @recent_signups = Subscription.includes(:academy, :plan).order(created_at: :desc).limit(10)
      @expiring_trials = Subscription.expiring_soon.includes(:academy, :plan).order(:trial_ends_at)
      @churn_rate = calculate_churn_rate
      @mrr_growth = 0#calculate_mrr_growth
    end

    # GET /admin/billing/subscriptions
    # List all subscriptions with filtering
    def subscriptions
      @subscriptions = Subscription.includes(:academy, :plan)

      # Filters
      @subscriptions = @subscriptions.where(status: params[:status]) if params[:status].present?
      @subscriptions = @subscriptions.where(plan_id: params[:plan]) if params[:plan].present?
      @subscriptions = @subscriptions.where('academies.name ILIKE ?', "%#{params[:search]}%") if params[:search].present?

      @subscriptions = @subscriptions.page(params[:page]).per(25)
      @plans = Plan.all
    end

    # GET /admin/billing/analytics
    # Detailed analytics and reporting
    def analytics
      @page_title = "Billing Analytics"
      @mrr_trend = calculate_mrr_trend
      @churn_analysis = calculate_churn_analysis
      @ltv_analysis = calculate_ltv_analysis
      @acquisition_funnel = calculate_acquisition_funnel
    end

    private

    def authenticate_superadmin!
      redirect_to root_path, alert: "Unauthorized" unless current_user&.superadmin?
    end

    def calculate_total_mrr
      Subscription.active_subscriptions.joins(:plan).sum("plans.price_cents") / 100.0
    end

    def calculate_plan_distribution
      Subscription.active_subscriptions
        .joins(:plan)
        .group("plans.name")
        .count
    end

    def calculate_churn_rate
      canceled_this_month = Subscription
        .where(status: :canceled)
        .where("canceled_at >= ?", 1.month.ago)
        .count

      total_subscriptions = Subscription.where("created_at < ?", 1.month.ago).count

      return 0 if total_subscriptions.zero?

      (canceled_this_month.to_f / total_subscriptions * 100).round(2)
    end

    def calculate_mrr_growth
      current_mrr = calculate_total_mrr
      previous_month_start = 1.month.ago.beginning_of_month
      previous_month_end = 1.month.ago.end_of_month

      # Simplified: calculate MRR for previous month
      previous_mrr = Subscription
        .active_subscriptions
        .where("created_at < ?", previous_month_end)
        .joins(:plan)
        .sum("plans.price_cents") / 100.0

      return 0 if previous_mrr.zero?

      (((current_mrr - previous_mrr) / previous_mrr) * 100).round(2)
    end

    def calculate_mrr_trend
      # Last 12 months of MRR data
      (12.months.ago..Time.current).group_by { |date| date.beginning_of_month }.map do |month, _dates|
        subscriptions_at_month = Subscription
          .where("created_at <= ?", month.end_of_month)
          .where("canceled_at IS NULL OR canceled_at > ?", month.end_of_month)
          .active_subscriptions

        mrr = subscriptions_at_month.joins(:plan).sum("plans.price_cents") / 100.0
        { month: month.strftime("%B %Y"), mrr: mrr }
      end
    end

    def calculate_churn_analysis
      # Churn by plan tier
      Plan.all.map do |plan|
        canceled = Subscription
          .where(plan: plan, status: :canceled)
          .where("canceled_at >= ?", 1.month.ago)
          .count

        total = Subscription
          .where(plan: plan)
          .where("created_at < ?", 1.month.ago)
          .count

        churn_rate = total.zero? ? 0 : (canceled.to_f / total * 100).round(2)

        { plan: plan.name, churn_rate: churn_rate, canceled: canceled, total: total }
      end
    end

    def calculate_ltv_analysis
      # Lifetime value per plan (simplified)
      Plan.all.map do |plan|
        avg_months = Subscription
          .where(plan: plan)
          .map { |sub| ((sub.canceled_at || Time.current) - sub.created_at) / 1.month.to_i }
          .sum / Subscription.where(plan: plan).count.to_f

        ltv = (plan.price_cents / 100.0) * avg_months

        { plan: plan.name, ltv: ltv.round(2), avg_months: avg_months.round(1) }
      end
    end

    def calculate_acquisition_funnel
      total_visitors = 100 # Placeholder, implement proper tracking
      signups = User.where("created_at >= ?", 1.month.ago).count
      trial_starts = Subscription.where("created_at >= ?", 1.month.ago).count
      conversions = Subscription
        .where(status: :active)
        .where("created_at >= ?", 1.month.ago)
        .where("plan_id != ?", Plan.find_by(tier: 'free').id)
        .count

      {
        visitors: total_visitors,
        signups: signups,
        signups_rate: ((signups.to_f / total_visitors) * 100).round(1),
        trials: trial_starts,
        trial_rate: ((trial_starts.to_f / signups) * 100).round(1),
        conversions: conversions,
        conversion_rate: ((conversions.to_f / trial_starts) * 100).round(1)
      }
    end
  end
end
