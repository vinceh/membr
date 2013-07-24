class Usercharge < ActiveRecord::Base

  belongs_to :user

  attr_accessible :stripe_charge_id, :amount, :stripe_fee, :number_of_members

  def to_json
    {
      id: id,
      date_billed: created_at.strftime("%b %d, %Y"),
      amount: sprintf("$%.2f", amount.to_f/100)
    }
  end
end