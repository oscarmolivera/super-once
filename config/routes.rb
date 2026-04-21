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
  # {slug}.nubbe.net — Academy tenant
  # ─────────────────────────────────────────────
  constraints subdomain: /\A(?!www\z|admin\z).+\z/ do

    # ── Public (no auth required) ──────────────
    get "welcome", to: "pages#academy", as: :academy_welcome
    get  "invitations/:token", to: "invitations#accept",  as: :accept_invitation
    post "invitations/:token", to: "invitations#confirm"

    # ── Auth (Rails 8 generated) ───────────────
    resource  :session
    resources :passwords, param: :token

    # ── Authenticated tenant routes ────────────
    root "dashboard#index", as: :tenant_root

    resource :profile, only: %i[show edit update]

    resource :academy_settings, only: %i[show edit update]

    resources :memberships, only: %i[index new create destroy] do
      member { patch :promote }
    end

    resources :invitations, only: %i[new create]

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

  get "up" => "rails/health#show", as: :rails_health_check
  get "manifest"       => "rails/pwa#manifest",      as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
