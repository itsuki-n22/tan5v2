Rails.application.routes.draw do

  root 'top#index'

  get 'login', to: 'sessions#new', as: :login
  resource :session, only: [:create, :destroy]

  post 'change_favorite', to: 'favorites#change'
  resources :tango_configs, only: %i[update]

  resources :users, shallow: true, except: %i[destroy] do
    get :search, on: :collection
    get :suspend, on: :member
    resources :wordnotes, only: [:show], shallow: false do
      post 'download_csv', to: 'wordnotes#download_csv'
      post 'upload_csv', to: 'wordnotes#upload_csv'
    end
    resources :wordnotes, except: %i[index new edit show] do
      resources :tangos, only: %i[create update destroy] do
        resource :tango_data, only: %i[show update], shallow: false
      end
      delete 'delete_checked_tangos', to: 'tangos#delete_checked_tangos', as: 'delete_checked_tangos_on', on: :member
      post 'create_on_list', to: 'tangos#create_on_list', as: 'create_tangos_on_list_of', on: :member
    end
  end
end
