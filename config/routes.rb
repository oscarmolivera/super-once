Rails.application.routes.draw do
  # ─────────────────────────────────────────────
  # www.nubbe.net — public marketing site
  # ─────────────────────────────────────────────
  constraints subdomain: "www" do
    root "pages#index", as: :www_root
    get "about",   to: "pages#about"
    get "pricing", to: "pages#pricing"
    get "contact", to: "pages#contact"

    # ── Onboarding flow ──────────────────────────
    namespace :onboarding do
      get  "start",          to: "wizard#start",              as: :start
      get  "step_1",         to: "wizard#step_1",             as: :step_1
      post "step_1",         to: "wizard#step_1"
      get  "step_2",         to: "wizard#step_2",             as: :step_2
      post "step_2",         to: "wizard#step_2"
      get  "step_3",         to: "wizard#step_3",             as: :step_3
      post "step_3",         to: "wizard#step_3"
      get  "step_3/checkout", to: "wizard#step_3_checkout",   as: :step_3_checkout
      get  "step_4",         to: "wizard#step_4",             as: :step_4
      post "step_4",         to: "wizard#step_4"
      get  "step_5",         to: "wizard#step_5",             as: :step_5
      post "create_academy", to: "wizard#create_academy",     as: :create_academy
    end
  end

  # ─────────────────────────────────────────────
  # admin.nubbe.net — superadmin Administrate panel
  # ─────────────────────────────────────────────
  constraints subdomain: "admin" do
    namespace :admin do
      resources :academies
      resources :users
      resources :memberships
      resource  :session
      resources :passwords, param: :token

      # ── Billing Dashboard ────────────────────────────
      get  "billing",              to: "billing_dashboard#index",        as: :billing
      get  "billing/subscriptions", to: "billing_dashboard#subscriptions", as: :billing_subscriptions
      get  "billing/analytics",    to: "billing_dashboard#analytics",    as: :billing_analytics

      root to: "academies#index"
    end
  end

  # ─────────────────────────────────────────────
  # {slug}.nubbe.net — Academy tenant
  # ─────────────────────────────────────────────
  constraints subdomain: /\A(?!www\z|admin\z).+\z/ do

    # ── Public (no auth required) ──────────────
    get "welcome",             to: "pages#academy",       as: :academy_welcome
    get  "invitations/:token", to: "invitations#accept",  as: :accept_invitation
    post "invitations/:token", to: "invitations#confirm"

    # ── Auth (Rails 8 generated) ───────────────
    resource  :session
    resources :passwords, param: :token

    # ── Authenticated tenant routes ────────────
    root "dashboard#index", as: :tenant_root

    resource :profile,          only: %i[show edit update]
    resource :academy_settings, only: %i[show edit update]

    resources :memberships, only: %i[index new create destroy] do
      member { patch :promote }
    end

    resources :invitations, only: %i[new create]

    # ── Enterprise pillar ─────────────────────────────────────
    namespace :enterprise do
      root "dashboard#index"

      resources :employees
      resources :salaries do
        collection { post :generate_month }
      end
      resources :income_expenses
      resources :player_payments do
        member { patch :mark_paid }
      end
      resources :inventory_items
      resources :tax_permits
    end

    namespace :school do
      root "dashboard#index"

      resources :categories
      resources :players
      resources :practice_sessions do
        member do
          get  :attendance
          patch :attendance
        end
      end
      resources :announcements
    end

    namespace :club do
      root "dashboard#index"

      resources :cups do
        resources :tournaments, shallow: true
      end

      resources :tournaments, only: %i[index]

      resources :cup_teams do
        member do
          get  :roster
          patch :roster
        end
      end

      resources :matches
    end

    # ── Billing (Academy) ────────────────────────────────────
    namespace :academy do
      resource :billing, only: %i[show] do
        member do
          post :checkout
          get  :checkout_success, as: :success
          post :customer_portal
          post :cancel
          post :reactivate
        end
      end
    end
  end

  # ─────────────────────────────────────────────
  # Stripe Webhooks
  # ─────────────────────────────────────────────
  namespace :stripe do
    post "webhooks", to: "webhooks#create", as: :webhooks
  end

  get "up" => "rails/health#show", as: :rails_health_check
  get "manifest"       => "rails/pwa#manifest",      as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
