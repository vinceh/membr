class MembersController < ApplicationController
  protect_from_forgery

  before_filter :authenticate_user!, :except => [:invitation, :invite_failure, :invite_success, :public_membership]

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

        if @member.valid?
          begin
          customer = Stripe::Customer.create(
            :card  => params[:stripeToken],
            :plan => membership.id
          )

          @member.stripe_customer_id = customer.id
          @member.save

          MemberMailer.joined_membership(@member, membership).deliver

          creatable.destroy
          redirect_to :action => :invite_success

          rescue Stripe::CardError => e
            flash[:error] = e.message
            redirect_to charges_path
          end
        end
      end
    end
  end

  def edit
    @member = current_user.member(params[:id])

    if request.put?
      @member = current_user.member(params[:id])

      if @member.update_attributes(params[:member])
        redirect_to member_success_path
      end
    end
  end

  def public_membership
    @user = User.find(params[:id])
    @member = Member.new

    if request.post?
      membership = Membership.find(params[:membership])

      if membership
        @member = Member.new(params[:member])
        @member.developer = false
        @member.membership = membership

        if @member.valid?
          begin
            customer = Stripe::Customer.create(
              :card  => params[:stripeToken],
              :plan => membership.id
            )

            @member.stripe_customer_id = customer.id
            @member.save

            MemberMailer.joined_membership(@member, membership).deliver

            redirect_to :action => :invite_success

          rescue Stripe::CardError => e
            flash[:error] = e.message
            redirect_to charges_path
          end
        end
      end
    end
  end

  # API
  def get_all_active
    members = current_user.members

    returnee = []

    if members
      members.each do |m|
        returnee << m.to_json if m.active
      end
    end

    render :json => returnee.to_json
  end

  def get_all_inactive
    members = current_user.members

    returnee = []

    if members
      members.each do |m|
        returnee << m.to_json if !m.active
      end
    end

    render :json => returnee.to_json
  end

  def invite
    creatable = Creatable.new(params[:creatable])
    membership = current_user.membership(creatable.membership.id)

    if membership && creatable.save!
      MemberMailer.send_invite(creatable).deliver
      render :json => {success: true}
    else
      render :json => {success: false, message: "Failed to send invite"}
    end
  end

  def bulk_invite
    if Member.bulk_invite(params[:bulk_invite_file], current_user)
      render :json => {success: true}
    else
      render :json => {success: false, message: "Incorrect format or invalid membership names"}
    end
  end

  def invoices_for
    member = current_user.member(params[:id])

    event = Stripe::Invoice.all(
      :customer => member.stripe_customer_id,
      :count => 5
    )

    event.data.each do |i|
      i.date = Time.at(i.date).strftime("%b %m, %Y")
    end

    render :json => {invoices: event.data}
  end

  def cancel_member
    member = current_user.member(params[:id])

    if member && member.cancel_subscription
      MemberMailer.cancel_membership(member, member.membership).deliver
      render :json => {success: true}
    else
      render :json => {success: false, message: "There was an error with your request"}
    end
  end

  def change_membership
    member = current_user.member(params[:id])
    membership = current_user.membership(params[:membership_id])

    if member && membership
      new_member = member.change_subscription(membership)
      if new_member
        MemberMailer.change_membership(member, membership).deliver
        render :json => {success: true, member: new_member.to_json}
      else
        render :json => {success: false, message: "There was an error with your request"}
      end
    else
      render :json => {success: false, message: "There was an error with your request"}
    end
  end
end
