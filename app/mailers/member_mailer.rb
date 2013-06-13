class MemberMailer < ActionMailer::Base
  default from: "c.tnecniv@gmail.com"

  def send_invite(creatable, membership)
    @creatable = creatable
    @membership = membership
    mail(:to => @creatable.email, :subject => "Membership Invite")
  end
end
