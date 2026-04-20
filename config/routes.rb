Rails.application.routes.draw do
  namespace :admin do
      resources :sessions
      resources :users

      root to: "sessions#index"
    end
  resource :session
  resources :passwords, param: :token
  root "pages#placeholder"
  get "up" => "rails/health#show", as: :rails_health_check
end