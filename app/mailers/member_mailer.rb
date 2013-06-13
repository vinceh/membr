class MemberMailer < ActionMailer::Base
  default from: "c.tnecniv@gmail.com"

  def send_invite(creatable)
    @creatable = creatable
    @membership = creatable.membership
    mail(:to => @creatable.email, :subject => "Membership Invite")
  end
end
