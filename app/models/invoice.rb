class Invoice < ActiveRecord::Base

  belongs_to :member

  attr_accessible :stripe_charge_id, :amount, :stripe_fee, :paid_out

  def self.gather_from_user(user)
    memberships =  user.memberships

    invoices = []
    memberships.each do |m|
      invoices << m.invoices.order('created_at DESC')
    end

    invoices.flatten!.group_by { |i| i.created_at.beginning_of_week }
  end

  def self.user_has_outstanding_invoices(user)
    memberships =  user.memberships

    memberships.each do |m|
      if m.invoices.where(paid_out: false).all.length > 0
        return true
      end
    end

    false
  end
end