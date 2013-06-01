class Membership < ActiveRecord::Base
  belongs_to :user
  has_many :members

  validates_presence_of :name, :is_private, :fee, :renewal_period
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
      fee: fee,
      renewal_period: renewal_period
    }
  end
end
