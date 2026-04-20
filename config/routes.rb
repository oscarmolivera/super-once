Rails.application.routes.draw do
  # ─────────────────────────────────────────────
  # www.nubbe.net — public marketing site
  # ─────────────────────────────────────────────
  constraints subdomain: "www" do
    root "pages#index", as: :www_root
    get "about",   to: "pages#about"
    get "pricing", to: "pages#pricing"
    get "contact", to: "pages#contact"
  end

  # ─────────────────────────────────────────────
  # admin.nubbe.net — superadmin Administrate panel
  # ─────────────────────────────────────────────
  constraints subdomain: "admin" do
    namespace :admin do
      resources :academies
      resources :users
      resources :memberships
      root to: "academies#index"
    end
  end

  # ─────────────────────────────────────────────
  # {slug}.nubbe.net — Academy tenant dashboard
  # Any subdomain that isn't www or admin
  # ─────────────────────────────────────────────
  constraints subdomain: /\A(?!www\z|admin\z).+\z/ do
    # Rails 8 auth — session management
    resource  :session
    resources :passwords, param: :token

    # Dashboard root (post-login)
    root "dashboard#index", as: :tenant_root

    # Academy settings
    resource :academy_settings, only: %i[show edit update]

    # Members management
    resources :memberships, only: %i[index new create destroy]
    resources :invitations, only: %i[new create]

    # Pillar namespaces (built in Phases 3-5)
    namespace :enterprise do
      root "dashboard#index"
    end

    namespace :school do
      root "dashboard#index"
    end

    namespace :club do
      root "dashboard#index"
    end
  end

  # Health check (no subdomain constraint — Kamal/load balancer)
  get "up" => "rails/health#show", as: :rails_health_check

  # PWA
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
