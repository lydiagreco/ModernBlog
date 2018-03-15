Rails.application.routes.draw do
  get '/auth/:provider/callback', to: 'sessions#create'
  resources :blogs do
    member do
      get :toggle_status
    end
  end
end
