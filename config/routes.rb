Membr::Application.routes.draw do

  devise_for :users do
    get 'home', :to => 'users#home', :as => :user_root
  end

  devise_for :admins, :skip => [:registration]

  root :to => "home#index"

  # API

  # membership
  post 'api/memberships/create' => 'memberships#create'
  get '/api/memberships/all' => 'memberships#get_all'

  # member
  post 'api/member/invite' => 'members#invite'
  get '/api/members/all' => 'members#get_all'
end
