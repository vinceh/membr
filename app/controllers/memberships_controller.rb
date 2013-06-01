class MembershipsController < ApplicationController
  protect_from_forgery

  # API
  def create
    m = Membership.new(params[:membership])

    if m.save!
      render :json => success(m.to_json)
    else
      render :json => error(m.errors)
    end
  end

  def retrieve
    m = Membership.find(params[:id])

    if m
      render :json => success(m.to_json)
    else
      render :json => error("Invalid memership ID")
    end
  end

  def update
    m = Membership.find(params[:id])
    m.update_attributes(params[:membership])

    if m.save!
      render :json => success(m.to_json)
    else
      render :json => error(m.errors)
    end
  end

  # TODO
  def delete
    m = Membership.find(params[:id])

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
