class MemberMailer < ActionMailer::Base
  default from: "c.tnecniv@gmail.com"

  def send_invite(creatable)
    @creatable = creatable
    @membership = creatable.membership
    mail(:to => @creatable.email, :subject => "Membership Invite")
  end

  def joined_membership(member, membership)
    @member = member
    @membership = membership
    mail(:to => @member.email, :subject => "Thank you for joining #{@membership.name}")
  end

  def invoice(member, membership)
    @member = member
    @membership = membership
    mail(:to => @member.email, :subject => "[billing] Your Membr invoice for #{Time.now.strftime("%b %d, %Y")} is available")
  end

  def cancel_membership(member, membership)
    @member = member
    @membership = membership
    mail(:to => @member.email, :subject => "Your Membr membership has been canceled")
  end

  def change_membership(member, membership)
    @member = member
    @membership = membership
    mail(:to => @member.email, :subject => "Your Membr membership has been changed")
  end

  def paymenter(paymenter)
    @paymenter = paymenter
    mail(:to => @paymenter.member.email, :subject => "Please update your payment details")
  end

  def payment_updated(member)
    @member = member
    mail(:to => @member.email, :subject => "Your payment details have been udpated")
  end
end
