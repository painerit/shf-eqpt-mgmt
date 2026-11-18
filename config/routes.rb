Rails.application.routes.draw do
  root "dashboard#index"

  get "login", to: "sessions#new", as: :login
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy", as: :logout

  get "signup", to: "registrations#new", as: :signup
  post "signup", to: "registrations#create"

  get "up", to: "health#show", as: :health_check

  namespace :admin do
    resources :users, only: [:index, :new, :create, :edit, :update]
  end
end