class Membership < ActiveRecord::Base
  belongs_to :user
  has_many :members

  validates_presence_of :name, :fee, :renewal_period
  validates_inclusion_of :is_private, :in => [true, false]
  attr_accessible :user_id, :name, :is_private, :fee, :renewal_period

  validates :fee, :numericality => { :greater_than_or_equal_to   => 0 }

  validates_each :renewal_period do |record, attr, value|
    record.errors.add(attr, ' is invalid') if !RENEWAL_PERIODS.has_value?(value)
  end

  RENEWAL_PERIODS = {
    ANNUALLY: 1,
    QUARTERLY: 2,
    MONTHLY: 3,
    WEEKLY: 4
  }

  def to_json
    {
      id: id,
      name: name,
      is_private: is_private,
      is_private_text: public_text,
      fee: fee,
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

  def renewal_text
    if renewal_period == RENEWAL_PERIODS[:ANNUALLY]
      "annum"
    elsif renewal_period == RENEWAL_PERIODS[:QUARTERLY]
      "quarter"
    elsif renewal_period == RENEWAL_PERIODS[:MONTHLY]
      "month"
    elsif renewal_period == RENEWAL_PERIODS[:WEEKLY]
      "week"
    end
  end

  def send_invite
    m = Membership.new
  end
end
