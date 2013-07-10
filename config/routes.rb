Membr::Application.routes.draw do

  devise_for :users do
    get 'home', :to => 'users#home', :as => :user_root
  end

  devise_for :admins, :skip => [:registration]

  root :to => "home#index"

  get 'invitation/error' => 'members#invite_failure', :as => :invite_failure
  get 'invitation/success' => 'members#invite_success', :as => :invite_success
  get 'member/success' => 'members#member_update_success', :as => :member_success
  get 'invitation/:token' => 'members#invitation', :as => :invite
  post 'invitation/:token' => 'members#invitation', :as => :members_create

  get 'memberships/:id/join' => 'members#public_membership', :as => :public_invite
  post 'memberships/:id/join' => 'members#public_membership', :as => :members_public_create

  get 'member/:id/edit' => 'members#edit', :as => :edit_member
  put 'member/:id/edit' => 'members#edit', :as => :update_member

  # Stripe Webhook
  post 'stripe-event' => 'events#stripe_event'
  get 'test-stripe' => 'events#test_stripe'
  get 'test-stripe2' => 'events#test_stripe2'

  # API

  # membership
  post 'api/memberships/create' => 'memberships#create'
  get 'api/memberships/all' => 'memberships#get_all'

  # member
  post 'api/member/invite' => 'members#invite'
  get 'api/members/all' => 'members#get_all_active'
  get 'api/members/all_inactive' => 'members#get_all_inactive'
  post 'api/members/bulkInvite' => 'members#bulk_invite'
  post 'api/members/change' => 'members#change_membership'
  get 'api/members/invoice/:id' => 'members#invoices_for'
  put 'api/members/cancel/:id' => 'members#cancel_member'
end
