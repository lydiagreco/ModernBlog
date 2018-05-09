Rails.application.routes.draw do
  get '/auth/:provider/callback', to: 'sessions#create'
  post '/auth/:provider/callback', to: 'sessions#create'
  devise_for :users, :controllers => { omniauth_callbacks: 'omniauth_callbacks' }
  match '/users/:id/finish_signup' => 'users#finish_signup', via: [:get, :patch], :as => :finish_signup
  match 'auth/:provider/callback', to: 'sessions#create', via: [:get, :blog]
  match 'auth/failure', to: redirect('/'), via: [:get, :blog]
  match 'signout', to: 'sessions#destroy', as: 'signout', via: [:get, :blog]

  resources :identities
  resources :blogs do
    member do
      get :toggle_status
    end
    collection do
      get :search
    end
  end
  root to: "blogs#index"
end
