Membr::Application.routes.draw do

  devise_for :users do
    get 'home', :to => 'users#home', :as => :user_root
  end

  devise_for :admins, :skip => [:registration]

  root :to => "home#index"

  get 'invitation/error' => 'members#invite_failure', :as => :invite_failure
  get 'invitation/success' => 'members#invite_success', :as => :invite_success
  get 'invitation/:token' => 'members#invitation', :as => :invite
  post 'invitation/:token' => 'members#invitation', :as => :members_create

  get 'memberships/:id/join' => 'members#public_membership', :as => :invite
  post 'memberships/:id/join' => 'members#public_membership', :as => :members_public_create

  # Stripe Webhook
  post '/stripe-event' => 'events#stripe_event'
  get '/test-stripe' => 'events#test_stripe'

  # API

  # membership
  post 'api/memberships/create' => 'memberships#create'
  get '/api/memberships/all' => 'memberships#get_all'

  # member
  post 'api/member/invite' => 'members#invite'
  get '/api/members/all' => 'members#get_all'
end
