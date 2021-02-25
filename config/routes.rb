Rails.application.routes.draw do

  root 'top#index'

  get 'login', to: 'sessions#new', as: :login
  resource :session, only: [:create, :destroy]

  post 'change_favorite', to: 'favorites#change'
  resources :tango_configs, only: %i[update]

  resources :users, shallow: true, except: %i[destroy] do
    get :search, on: :collection
    get :suspend, on: :member
    resources :wordnotes, except: %i[index new edit] do
      resources :tangos, only: %i[index create update destroy] do
        post :import, on: :collection
        resource :tango_data, only: %i[show update], shallow: false
      end
    end
  end
end
