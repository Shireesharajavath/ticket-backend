Rails.application.routes.draw do
  # === Authentication Routes ===
  post "/signup", to: "users#create"      # Signup
  post "/login", to: "sessions#create"    # Login
  delete "/logout", to: "sessions#destroy" # Logout

  # === Ticket Routes ===
  get "/tickets/search", to: "tickets#search"
  resources :tickets, except: [:destroy] do
    resources :comments, only: [:index, :create, :update, :destroy]
  end

  # === User Routes ===
  get "/users/:id", to: "users#show"
  put "/users/:id", to: "users#update"
  get '/current_user', to: 'users#me'


  # === Convenience routes ===
  get "/my/created", to: "tickets#created_by_me"
  get "/my/assigned", to: "tickets#assigned_to_me"
end
