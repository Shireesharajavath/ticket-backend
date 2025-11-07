Rails.application.routes.draw do
  # === Authentication Routes ===
  post "/signup", to: "users#create"      # Signup (register a new user)
  post "/login", to: "sessions#create"    # Login (generate JWT token)
  delete "/logout", to: "sessions#destroy"

  get "/tickets/search", to: "tickets#search"

  get "/users/:id", to: "users#show"
   put "/users/:id", to: "users#update"
  # === Ticket Routes ===
  resources :tickets, except: [:destroy] do
    # Nested comments routes (each ticket has many comments)
    resources :comments, only: [:index, :create, :update, :destroy]
  end

  # === Convenience routes ===
  get "/my/created", to: "tickets#created_by_me"     # Tickets created by logged-in user
  get "/my/assigned", to: "tickets#assigned_to_me"   # Tickets assigned to logged-in user
end
