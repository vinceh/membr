class Membership < ActiveRecord::Base

  belongs_to :user
  has_many :members
  has_many :invoices, :through => :members

  validates_presence_of :name, :fee, :renewal_period
  validates_inclusion_of :is_private, :in => [true, false]
  attr_accessible :user_id, :name, :is_private, :fee, :renewal_period

  validates :fee, :numericality => { :greater_than_or_equal_to => 500 }

  validates_each :renewal_period do |record, attr, value|
    valid = false

    RENEWAL_PERIODS.each do |k, v|
      valid = valid || v[:value] == value
    end

    unless valid
      record.errors.add(attr, ' is invalid')
    end
  end

  RENEWAL_PERIODS = {
    ANNUALLY: {
      value: 1,
      stripe: 'year',
      interval: 1
    },
    QUARTERLY: {
      value: 2,
      stripe: 'month',
      interval: 3
    },
    MONTHLY: {
      value: 3,
      stripe: 'month',
      interval: 1
    },
    WEEKLY: {
      value: 4,
      stripe: 'week',
      interval: 1
    }
  }

  def get_interval
    RENEWAL_PERIODS.each do |k, v|
      return v[:stripe] if v[:value] == renewal_period
    end
  end

  def get_interval_count
    RENEWAL_PERIODS.each do |k, v|
      return v[:interval] if v[:value] == renewal_period
    end
  end

  def to_json
    {
      id: id,
      name: name,
      is_private: is_private,
      is_private_text: public_text,
      fee: fee,
      fee_text: display_fee,
      renewal_period: renewal_period,
      renewal_period_text: renewal_text,
      created_at: created_at.strftime("%b %d, %Y"),
      members: members.length
    }
  end

  def public_text
    if is_private
      "Invite only"
    else
      "Public"
    end
  end

  def display_fee
    '$'+sprintf("%.2f", fee.to_f/100)
  end

  def renewal_text
    if renewal_period == RENEWAL_PERIODS[:ANNUALLY][:value]
      "annum"
    elsif renewal_period == RENEWAL_PERIODS[:QUARTERLY][:value]
      "quarter"
    elsif renewal_period == RENEWAL_PERIODS[:MONTHLY][:value]
      "month"
    elsif renewal_period == RENEWAL_PERIODS[:WEEKLY][:value]
      "week"
    end
  end

  def update_membership(attr)
    self.name = attr[:name]
    self.is_private = attr[:is_private]
    save!
    self
  end

  def update_stripe_name
    Stripe.api_key = self.user.stripe_token
    p = Stripe::Plan.retrieve(id.to_s)
    p.name = name
    p.save
  end

  def stripe_delete
    self.archived = true
    save!
    Stripe.api_key = self.user.stripe_token
    plan = Stripe::Plan.retrieve(id.to_s)
    plan.delete

    members.each do |m|
      m.cancel_subscription
    end

    members
  end
end
