class MembershipsController < ApplicationController
  protect_from_forgery

  before_filter :authenticate_user!

  # API
  def create
    m = Membership.new(params[:membership])
    m.user = current_user

    if m.save!
      Stripe.api_key = current_user.stripe_token
      Stripe::Plan.create(
        :amount => m.fee,
        :interval => m.get_interval,
        :interval_count => m.get_interval_count,
        :name => m.name,
        :currency => current_user.currency,
        :id => m.id
      )
      render :json => success(m.to_json)
    else
      render :json => error(m.errors)
    end
  end

  def update
    m = current_user.membership(params[:id])
    if m && m.update_membership(params[:membership])
      m.update_stripe_name

      members = Member.all_active(current_user)

      render :json => {success: true, membership: m.to_json, members: members}
    else
      render :json => error("Failed to update membership")
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

  def get_all
    memberships = current_user.memberships.where(archived: false).order("created_at ASC")

    returnee = []
    memberships.each do |m|
      returnee << m.to_json
    end

    render :json => returnee.to_json
  end

  def delete
    m = current_user.membership(params[:id])

    if m
      new_members = m.stripe_delete
      members = Member.all_active(current_user)

      if new_members
        render :json => {success: true, members: members}
      else
        render :json => {success: true}
      end
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
