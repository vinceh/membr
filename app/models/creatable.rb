class Creatable < ActiveRecord::Base

  before_create :generate_token

  protected

  def generate_token
    self.token = loop do
      random_token = SecureRandom.urlsafe_base64
      break random_token unless Creatable.where(token: random_token).exists?
    end
  end
end