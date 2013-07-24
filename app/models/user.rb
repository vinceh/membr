class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :lockable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :full_name, :organization, :tos,
                  :street_address, :city, :state, :country, :zipcode, :phone_number, :stripe_customer_id
  # attr_accessible :title, :body

  validates_presence_of :full_name, :organization, :street_address, :city, :state, :country, :zipcode, :phone_number
  validates :tos, :acceptance => true, :on => :create

  has_many :memberships
  has_many :usercharges
  has_many :members, :through => :memberships

  def member(id)
    members.where(:id => id).first
  end

  def membership(id)
    memberships.where(:id => id).first
  end

  def invoice(id)
    usercharges.where(:id => id).first
  end

  def add_stripe(token)
    begin
      customer = Stripe::Customer.create(
        :card  => token
      )

      self.stripe_customer_id = customer.id
      save

      true
    rescue Stripe::CardError => e
      nil
    end
  end

  def next_bill_date
    months = months_since_created
    date = self.created_at + months.months

    if date.to_date < Time.now.to_date
      date = date + 1.month
    end

    return date
  end

  def requires_billing
    next_bill_date.to_date == Time.now.to_date
  end

  def next_bill_amount
    m = members.where(active: true).all

    if m.length > 10
      amount = (m.length-10)*ENV['MONTHLY_MEMBER_FEE'].to_i
      amount = amount.to_f/100
      sprintf("$%.2f", amount)
    else
      "$0.00"
    end
  end

  def bill
    m = members.where(active: true).all

    if m.length > 10
      Stripe::Charge.create(
        :amount => (m.length-10)*ENV['MONTHLY_MEMBER_FEE'].to_i,
        :currency => "cad",
        :customer => stripe_customer_id,
        :description => "Charge for #{m.length} members on #{Time.now.strftime("%b %d, %Y")}"
      )
    end
  end

  def address_text
    "#{self.street_address} #{self.city} #{self.state}, #{self.zipcode}"

  end

  private

  def months_since_created
    now = Time.now
    created = self.created_at
    (now.year * 12 + now.month) - (created.year * 12 + created.month)
  end
end
