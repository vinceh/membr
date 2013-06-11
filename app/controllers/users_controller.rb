class UsersController < ApplicationController
  protect_from_forgery

  before_filter :authenticate_user!

  def home

    @members = Member.all

    render :layout => "panel"
  end
end
