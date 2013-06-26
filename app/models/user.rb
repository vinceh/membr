class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :lockable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :full_name, :organization, :tos
  # attr_accessible :title, :body

  validates_presence_of :full_name, :organization
  validates :tos, :acceptance => true, :on => :create

  has_many :memberships

  def members
    members = []

    memberships.each do |m|
      members << m.members
    end

    members.flatten!
  end
end
