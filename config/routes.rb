Membr::Application.routes.draw do

  devise_for :users do
    get 'home', :to => 'users#home', :as => :user_root
  end

  devise_for :admins, :skip => [:registration]

  root :to => "home#index"

  # API
  post 'api/v1/memberships/create' => 'memberships#create'
end
