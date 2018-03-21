Rails.application.routes.draw do
  get '/auth/:provider/callback', to: 'sessions#create'
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  match 'auth/:provider/callback', to: 'sessions#create', via: [:get, :blog]
  match 'auth/failure', to: redirect('/'), via: [:get, :blog]
  match 'signout', to: 'sessions#destroy', as: 'signout', via: [:get, :blog]
  resources :blogs do
    member do
      get :toggle_status
    end
    collection do
      get :search
    end
  end
end
