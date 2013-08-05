class AdminsController < ApplicationController
  before_filter :authenticate_admin!

  def controlpanel
    @users = User.all
  end

  def user_detail
    @user = User.find(params[:id])
    @invoices = Invoice.gather_from_user(@user)
  end

  def mark_as_paid
    invoices = Invoice.gather_from_user(User.find(params[:id]))

    invoices[Time.at(params[:timestamp].to_i)].each do |i|
      i.paid_out = true
      i.save!
    end

    redirect_to :action => :user_detail, :id => params[:id]
  end

  def mark_as_unpaid
    invoices = Invoice.gather_from_user(User.find(params[:id]))

    invoices[Time.at(params[:timestamp].to_i)].each do |i|
      i.paid_out = false
      i.save!
    end

    redirect_to :action => :user_detail, :id => params[:id]
  end

  def beta_accounts
    @betas = Beta.all
  end
end
