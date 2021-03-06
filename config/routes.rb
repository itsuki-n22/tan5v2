Rails.application.routes.draw do

  root 'top#index'

  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'

  resources :favorites, only: %i[create destroy]
  resources :tango_configs, only: %i[update]
  resources :tango_data, only: %i[show update]

  resources :users, except: %i[destroy] do
    get :search, on: :collection
  end

  resources :wordnotes, except: %i[index new edit], shallow: true do
    resources :tangos, only: %i[index create update destroy] do
      post :import, on: :collection
    end
  end
end
