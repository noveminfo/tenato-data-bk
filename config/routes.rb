Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :data_sources do
        member do
          post :upload
          get 'import_status/:import_history_id', to: 'data_sources#import_status'
        end
      end
      post 'auth/login', to: 'auth#login'
      delete 'auth/logout', to: 'auth#logout'
      resources :users

      namespace :dashboard do
        get :summary
      end
    end
  end

  # Sidekiq Web UI（開発環境のみ）
  if Rails.env.development?
    require 'sidekiq/web'
    mount Sidekiq::Web => '/sidekiq'
  end
end
