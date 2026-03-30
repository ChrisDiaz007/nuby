Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"

  resources :users, only: [:index, :show, :edit, :create]

  resources :foods, only: [:show] do
    collection do
      get :scan
      post :lookup
    end
  end

  resources :user_foods, only: [:index, :create, :destroy]
end
