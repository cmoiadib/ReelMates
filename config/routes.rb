Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"

  get "up" => "rails/health#show", as: :rails_health_check

  resources :guests, only: [:new, :create]
  resources :parties, only: [:show, :new, :create] do
    resources :results, only: [:show]
    resources :swipes, only: [:new, :create]
  end
end
