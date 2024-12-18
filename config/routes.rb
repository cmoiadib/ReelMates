Rails.application.routes.draw do
  mount ActionCable.server => '/cable'
  devise_for :users
  root to: "pages#home"

  get "up" => "rails/health#show", as: :rails_health_check
  resources :users, only: [:update]
  resources :parties, only: %i[index show new create] do
    member do
      get :start
      put :start
      get :result
      get :final_result
      get :check_completion
    end
    resources :swipes, only: %i[index new create] do
      collection do
        post :undo
        post :final
      end
    end
  end
end
