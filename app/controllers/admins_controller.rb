class AdminsController < ApplicationController
  before_filter :authenticate_admin!

  def controlpanel
    @users = User.all
  end

  def user_detail
    @user = User.find(params[:id])
  end
end
