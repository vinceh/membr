class Member < ActiveRecord::Base
  belongs_to :membership

  validates_presence_of :membership_id, :email
  validates_presence_of :full_name, :street_address, :city, :state, :country, :zipcode, :phone, :if => "!developer"
  attr_accessible :membership_id, :full_name, :email, :street_address, :city, :state, :country, :zipcode, :phone, :developer, :create_token, :claim_date

  def generate_token
    self.create_token = loop do
      random_token = SecureRandom.urlsafe_base64
      break random_token unless Member.where(create_token: random_token).exists?
    end
  end

  def to_json
    {
      id: id,
      full_name: full_name,
      email: email,
      phone: phone,
      joined: created_at.strftime("%b %m, %Y"),
      payment: "paid",
      membership: membership.name
    }
  end
end