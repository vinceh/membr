class MembersController < ApplicationController
  protect_from_forgery

  before_filter :authenticate_user!

  # API
  def get_all
    members = current_user.members

    returnee = []
    members.each do |m|
      returnee << m.to_json
    end

    render :json => returnee.to_json
  end
end
