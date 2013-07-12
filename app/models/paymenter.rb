class Paymenter < ActiveRecord::Base

  before_create :generate_token
  belongs_to :member
  attr_accessible :member_id

  protected

  def generate_token
    self.token = loop do
      random_token = SecureRandom.urlsafe_base64
      break random_token unless Creatable.where(token: random_token).exists?
    end
  end
end