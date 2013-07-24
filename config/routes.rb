Membr::Application.routes.draw do

  devise_for :users, :controllers => { :registrations => "users/registrations" } do
    get 'home', :to => 'users#home', :as => :user_root
  end

  devise_for :admins, :skip => [:registration] do
    get 'controlpanel', :to => 'admins#controlpanel', :as => :admin_root
    get 'controlpanel/user/:id', :to => 'admins#user_detail', :as => :admin_user_detail
    post 'controlpanel/mark-as-paid/:id/:timestamp', :to => 'admins#mark_as_paid', :as => :mark_paid
    post 'controlpanel/mark-as-unpaid/:id/:timestamp', :to => 'admins#mark_as_unpaid', :as => :mark_unpaid
  end

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

  get 'invoices/:id' => 'users#invoice', :as => :invoice

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

  # user
  get 'api/user/account' => 'users#account_status'
end
