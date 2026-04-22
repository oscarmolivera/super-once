module Onboarding
  class WizardController < ApplicationController
    layout "onboarding"

    skip_before_action :authenticate_user!, only: %i[start step_1 step_2 step_3 step_4 step_5 step_3_checkout create_academy]
    before_action :validate_step_access, except: %i[start step_1 step_3_checkout]

    # Helper to track current step for progress bar
    def current_step
      case action_name
      when 'step_1'
        1
      when 'step_2'
        2
      when 'step_3', 'step_3_checkout'
        3
      when 'step_4'
        4
      when 'step_5'
        5
      else
        0
      end
    end

    helper_method :current_step

    # GET /onboarding/start
    # Initial landing page for new academies
    def start
      @plans = Plan.visible
    end

    # GET/POST /onboarding/step_1
    # Academy name and subdomain selection
    def step_1
      @form = Onboarding::Step1Form.new(session[:onboarding_data] || {})

      if request.post?
        if @form.validate(params[:onboarding_step1_form] || {})
          session[:onboarding_data] ||= {}
          session[:onboarding_data].merge!(@form.attributes)
          session[:onboarding_step] = 1
          redirect_to onboarding_step_2_path
        else
          render :step_1
        end
      end
    end

    # GET/POST /onboarding/step_2
    # Sport and category selection
    def step_2
      @form = Onboarding::Step2Form.new(session[:onboarding_data] || {})

      if request.post?
        if @form.validate(params[:onboarding_step2_form] || {})
          session[:onboarding_data].merge!(@form.attributes)
          session[:onboarding_step] = 2
          redirect_to onboarding_step_3_path
        else
          render :step_2
        end
      end
    end

    # GET/POST /onboarding/step_3
    # Plan selection
    def step_3
      @plans = Plan.visible
      @form = Onboarding::Step3Form.new(session[:onboarding_data] || {})

      if request.post?
        if @form.validate(params[:onboarding_step3_form] || {})
          session[:onboarding_data].merge!(@form.attributes)
          session[:onboarding_step] = 3

          # If free plan, skip to step 4 (first user)
          if @form.plan.free?
            redirect_to onboarding_step_4_path
          else
            redirect_to onboarding_step_3_checkout_path
          end
        else
          render :step_3
        end
      end
    end

    # GET /onboarding/step_3/checkout
    # Stripe checkout for paid plans
    def step_3_checkout
      @plan = Plan.find(session.dig(:onboarding_data, :plan_id))

      session_params = {
        payment_method_types: ['card'],
        mode: 'setup',
        success_url: onboarding_step_4_url,
        cancel_url: onboarding_step_3_url,
        metadata: {
          onboarding_session: session.id,
          plan_id: @plan.id
        }
      }

      @checkout_session = Stripe::Checkout::Session.create(session_params)
    end

    # GET /onboarding/step_4
    # First user creation
    def step_4
      @form = Onboarding::Step4Form.new(session[:onboarding_data] || {})

      if request.post?
        if @form.validate(params[:onboarding_step4_form] || {})
          session[:onboarding_data].merge!(@form.attributes)
          session[:onboarding_step] = 4
          redirect_to onboarding_step_5_path
        else
          render :step_4
        end
      end
    end

    # GET /onboarding/step_5
    # Review and confirm
    def step_5
      @onboarding_data = session[:onboarding_data] || {}
      render :step_5
    end

    # POST /onboarding/create_academy
    # Create the academy and subscription
    def create_academy
      result = Onboarding::CreateAcademyService.new(
        session[:onboarding_data],
        current_user
      ).call

      if result.success?
        session.delete(:onboarding_data)
        session.delete(:onboarding_step)

        # Log in the user
        session[:user_id] = result.user.id

        redirect_to tenant_root_url(subdomain: result.academy.slug),
                    notice: "Welcome to #{result.academy.name}!"
      else
        redirect_to onboarding_step_1_path, alert: result.errors.join(", ")
      end
    end

    private

    def validate_step_access
      current_step = action_name.match(/step_(\d)/)[1].to_i
      last_completed_step = session[:onboarding_step] || 0

      unless current_step == last_completed_step + 1 || current_step == last_completed_step
        redirect_to onboarding_step_1_path, alert: "Please complete the previous step first"
      end
    end
  end
end
