class Invoice < ActiveRecord::Base

  belongs_to :membership

  attr_accessible :stripe_charge_id, :amount, :stripe_fee, :paid_out
end