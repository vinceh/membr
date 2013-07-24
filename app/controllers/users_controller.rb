class UsersController < ApplicationController
  protect_from_forgery

  before_filter :authenticate_user!

  def home
    @members = Member.all

    render :layout => "panel"
  end

  def invoice
    @invoice = current_user.invoice(params[:id])
  end

  # API

  def account_status
    invoices = []
    current_user.usercharges.each do |c|
      invoices << c.to_json
    end

    render :json => {
      next_bill_date: current_user.next_bill_date.strftime("%b %d, %Y"),
      next_bill_amount: current_user.next_bill_amount,
      invoices: invoices
    }
  end
end
