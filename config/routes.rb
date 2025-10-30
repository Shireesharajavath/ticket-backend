Rails.application.routes.draw do
  # Authentication
  post "/signup", to: "users#signup"
  post "/login", to: "users#login"
  get "/me", to: "users#me"

  resources :tickets, only: [:index, :create, :show, :update, :destroy] do
  resources :comments, only: [:index, :create, :update, :destroy]
end


  # Convenience endpoints
  get "/my/created", to: "tickets#created_by_me"
  get "/my/assigned", to: "tickets#assigned_to_me"
end
