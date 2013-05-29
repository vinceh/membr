class UsersController < ApplicationController
  protect_from_forgery

  def home

    @m = Membership.all

    render :layout => "panel"
  end
end
