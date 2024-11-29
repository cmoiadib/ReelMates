Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"

  get "up" => "rails/health#show", as: :rails_health_check
  resources :users, only: [:update]
  resources :parties, only: %i[index show new create] do
    member do
      put :start
      get :start
    end
    resources :swipes, only: %i[index new create] do
      member do
        get :result
      end
    end
  end
end
