Rails.application.routes.draw do
  root "pages#placeholder"
  get "up" => "rails/health#show", as: :rails_health_check
end