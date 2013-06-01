class Member < ActiveRecord::Base
  belongs_to :membership

  validates_presence_of :membership_id, :developer
  validates_presence_of :full_name, :street_address, :city, :state, :country, :zipcode, :phone, :if => "!developer"
  attr_accessible :membership_id, :full_name, :street_address, :city, :state, :country, :zipcode, :phone, :developer
end