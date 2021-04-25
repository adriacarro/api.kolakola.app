Rails.application.routes.draw do
  mount ActionCable.server => '/cable'

  root to: 'application#root'

  namespace :v1 do

    # Auth
    scope path: 'auth' do
      post 'login', to: 'authentication#login'
      post 'guest', to: 'authentication#guest'
      post 'signup', to: 'authentication#signup'
      post 'forgot_password', to: 'authentication#forgot_password'
      post 'reset_password', to: 'authentication#reset_password'
    end

    resources :users do
      delete :logout, on: :member
      post :invite, on: :member
      post :break, on: :member
      delete :break, on: :member
    end

    resources :places, only: [:show, :update]
    resources :services do
      post :enqueue, on: :member
    end
    resources :lines, only: [:update, :delete] do
      post :yield, on: :member
    end
  end
end
