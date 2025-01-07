Rails.application.routes.draw do
  resources :rooms
  get 'password/resets'
  root 'pages#home'
  resource :dashboard, only: :show
  resource :registration, only: %i[new create]
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  resource :session, only: %i[new create destroy]
  resource :password_reset, only: %i[new create edit update]
  resource :password, only: %i[edit update]

  get 'user/:id', to: 'users#show', as: 'user'

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
