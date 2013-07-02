class MembershipsController < ApplicationController
  protect_from_forgery

  before_filter :authenticate_user!

  # API
  def create
    m = Membership.new(params[:membership])
    m.user = current_user

    if m.save!
      Stripe::Plan.create(
        :amount => m.fee,
        :interval => m.get_interval,
        :interval_count => m.get_interval_count,
        :name => m.name,
        :currency => 'cad',
        :id => m.id
      )
      render :json => success(m.to_json)
    else
      render :json => error(m.errors)
    end
  end

  def retrieve
    m = current_user.membership(params[:id])

    if m
      render :json => success(m.to_json)
    else
      render :json => error("Invalid memership ID")
    end
  end

  def update
    m = current_user.membership(params[:id])
    m.update_attributes(params[:membership])

    if m.save!
      render :json => success(m.to_json)
    else
      render :json => error(m.errors)
    end
  end

  def get_all
    memberships = current_user.memberships

    returnee = []
    memberships.each do |m|
      returnee << m.to_json
    end

    render :json => returnee.to_json
  end

  # TODO
  def delete
    m = current_user.membership(params[:id])

    if m && m.destroy!

    end
  end

  private

  def success(membership)
    {
      success: true,
      membership: membership
    }
  end

  def error(message)
    {
      success: false,
      message: message
    }
  end
end
