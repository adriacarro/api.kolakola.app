Rails.application.routes.draw do
  namespace :v1 do

    # Auth
    scope path: 'auth' do
      post 'login', to: 'authentication#login'
      post 'signup', to: 'authentication#signup'
      post 'forgot_password', to: 'authentication#forgot_password'
      post 'reset_password', to: 'authentication#reset_password'
    end

    resources :users do
      post :invite, on: :member
    end

    resources :places, only: [:show, :update]
    resources :services
  end
end
