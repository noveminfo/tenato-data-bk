Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :data_sources do
        collection do
          get :import_history  # 追加
        end

        member do
          post :upload
          get 'import_status/:import_history_id', to: 'data_sources#import_status'
        end
      end
      post 'auth/login', to: 'auth#login'
      get '/auth/me', to: 'auth#me'
      delete 'auth/logout', to: 'auth#logout'
      resources :users

      namespace :dashboard do
        get :summary
        get :charts
      end

      namespace :tenant do
        get :show
        patch :update_settings
      end
    end
  end

  # Sidekiq Web UI（開発環境のみ）
  if Rails.env.development?
    require 'sidekiq/web'
    mount Sidekiq::Web => '/sidekiq'
  end
end
