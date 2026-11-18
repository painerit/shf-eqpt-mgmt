Rails.application.routes.draw do
  root "dashboard#index"

  get "login", to: "sessions#new", as: :login
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy", as: :logout

  get "signup", to: "registrations#new", as: :signup
  post "signup", to: "registrations#create"

  get "up", to: "health#show", as: :health_check

  resources :equipment, only: [:index, :show, :new, :create, :edit, :update]

  resources :verification_schedules, only: [:index, :show, :new, :create, :edit, :update] do
    collection do
      post :generate
    end

    member do
      patch :approve
    end
  end

  resources :verifications, only: [:index, :show, :create, :edit, :update] do
    member do
      patch :start
      patch :complete
      patch :cancel
      get :protocol
    end
  end

  namespace :admin do
    resources :users, only: [:index, :new, :create, :edit, :update]
  end
end