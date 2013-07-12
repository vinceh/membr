class MembersController < ApplicationController
  protect_from_forgery

  before_filter :authenticate_user!, :except => [:invitation, :public_membership]

  def invitation
    @creatable = Creatable.find_by_token(params[:token])

    if !@creatable || (Time.now - @creatable.created_at) > 7.days
      render_error({
         :message => "This invitation is either invalid or has expired.  Contact the owner of the membership to request another invitation.",
         :route => root_url
       })
    end

    @member = Member.new

    if request.post?
      creatable = Creatable.find(params[:creatable_id])
      membership = creatable.membership

      if membership
        @member = Member.new(params[:member])
        @member.developer = false
        @member.membership = membership

        if @member.valid? && @member.join_membership(membership, params[:stripeToken])

          creatable.destroy
          render_success({
             :message => "You have successfully joined a membership.  Contact the membership owner if you have any questions.",
             :route => root_url
           })
        else
          flash[:error] = e.message
          redirect_to charges_path
        end
      end
    end
  end

  def edit
    @member = current_user.member(params[:id])

    if request.put?
      @member = current_user.member(params[:id])

      if @member.update_attributes(params[:member])
        render_success({
           :message => "Member updated.",
           :route => user_root_path
         })
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

          if @member.valid? && @member.join_membership(membership, params[:stripeToken])

            render_success({
                             :message => "You have successfully joined a membership.  Contact the membership owner if you have any questions.",
                             :route => root_url
                           })
          else
            flash[:error] = e.message
            redirect_to charges_path
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
      render :json => {success: true, member: member.to_json}
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

  def send_paymenter
    member = current_user.member(params[:id])

    if member
      paymenter = Paymenter.new
      paymenter.member = member

      if paymenter.save!
        MemberMailer.paymenter(paymenter).deliver
        render :json => {success: true}
      end
    end
  end

  def payment_update
    @paymenter = Paymenter.find_by_token(params[:token])

    if !@paymenter || (Time.now - @paymenter.created_at) > 7.days
      render_error({
        :message => "This payment update token is invalid or has expired.",
        :route => root_url
      })
    end

    if request.post?
      paymenter = Paymenter.find(params[:paymenter_id])
      @member = paymenter.member

      if @member.update_payment(params[:stripeToken])
        paymenter.destroy
        render_success({
          :message => "Your payment has been successfully updated.",
          :route => root_url
        })
      end
    end
  end
end
