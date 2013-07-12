Membr::Application.routes.draw do

  devise_for :users do
    get 'home', :to => 'users#home', :as => :user_root
  end

  devise_for :admins, :skip => [:registration]

  root :to => "home#index"

  get 'success' => 'home#success', :as => :success
  get 'error' => 'home#error', :as => :error

  get 'invitation/:token' => 'members#invitation', :as => :invite
  post 'invitation/:token' => 'members#invitation', :as => :members_create

  get 'paymentUpdate/:token' => 'members#payment_update', :as => :payment_change
  post 'paymentUpdate/:token' => 'members#payment_update', :as => :payment_update

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
  post 'api/memberships/update' => 'memberships#update'
  post 'api/memberships/delete/:id' => 'memberships#delete'

  # member
  post 'api/member/invite' => 'members#invite'
  get 'api/members/all' => 'members#get_all_active'
  get 'api/members/all_inactive' => 'members#get_all_inactive'
  post 'api/members/bulkInvite' => 'members#bulk_invite'
  post 'api/members/change' => 'members#change_membership'
  get 'api/members/invoice/:id' => 'members#invoices_for'
  put 'api/members/cancel/:id' => 'members#cancel_member'
  post 'api/members/sendPaymenter' => 'members#send_paymenter'
end
