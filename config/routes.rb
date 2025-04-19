Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :data_sources do
        member do
          post :upload
        end
      end
      post 'auth/login', to: 'auth#login'
      delete 'auth/logout', to: 'auth#logout'
      resources :users
    end
  end
end
