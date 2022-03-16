Rails.application.routes.default_url_options[:host] = "https://rails.iaruso.repl.co/"

Rails.application.routes.draw do
  root 'pages#index'
  get 'contact', to: 'pages#contact'
  get 'about', to: 'pages#about'

  post "sign_up", to: "users#create"
  get "sign_up", to: "users#new"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  resources :confirmations, only: [:create, :edit, :new], param: :confirmation_token

  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy"
  get "login", to: "sessions#new"

  resources :passwords, only: [:create, :edit, :new, :update], param: :password_reset_token

  put "account", to: "users#update"
  get "account", to: "users#edit"
  delete "account", to: "users#destroy"

  resources :active_sessions, only: [:destroy] do
    collection do
      delete "destroy_all"
    end
  end
  
end