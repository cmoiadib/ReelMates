Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"

  get "up" => "rails/health#show", as: :rails_health_check
  resources :users, only: [:update]
  resources :parties, only: [:index, :show, :new, :create] do
    member do
      put :start
      get :start
      get :result
    end
    resources :swipes, only: [:new, :create]
  end
end
