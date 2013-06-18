class MembersController < ApplicationController
  protect_from_forgery

  before_filter :authenticate_user!, :except => [:invitation, :invite_failure, :invite_success]

  def invitation
    @creatable = Creatable.find_by_token(params[:token])

    if !@creatable || (Time.now - @creatable.created_at) > 7.days
      redirect_to invite_failure_path
    end

    @member = Member.new

    if request.post?
      creatable = Creatable.find(params[:creatable_id])
      membership = creatable.membership

      if membership
        @member = Member.new(params[:member])
        @member.developer = false
        @member.membership = membership
        if @member.save
          # creatable.destroy
          redirect_to :action => :invite_success
        end
      end
    end
  end

  # API
  def get_all
    members = current_user.members

    returnee = []
    members.each do |m|
      returnee << m.to_json
    end

    render :json => returnee.to_json
  end

  def invite
    creatable = Creatable.new(params[:creatable])

    if creatable.save!
      MemberMailer.send_invite(creatable).deliver
      render :json => {success: true}
    else
      render :json => {success: false, message: "Failed to send invite"}
    end
  end
end
