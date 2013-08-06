class User < ActiveRecord::Base

  devise :omniauthable, :rememberable, :trackable

  attr_accessible :email, :remember_me, :organization,
                  :country, :currency, :stripe_account_id, :stripe_public_key, :stripe_token, :charge_enabled

  validates_presence_of :email, :country, :currency, :stripe_account_id, :stripe_public_key, :stripe_token, :charge_enabled, :organization

  has_many :memberships
  has_many :usercharges
  has_many :members, :through => :memberships

  def self.from_omniauth(obj)

    user = where(:stripe_account_id => obj["uid"]).first

    if user && !user.charge_enabled && acc["charge_enabled"]
      user.stripe_public_key = obj["info"]["stripe_publishable_key"]
      user.stripe_token = obj["credentials"]["token"]
      user.charge_enabled = acc["charge_enabled"]
      user.save!
    elsif !user
      Stripe.api_key = obj["credentials"]["token"]
      acc = Stripe::Account.retrieve()

      user = self.new
      user.email = acc["email"]
      user.organization = acc["statement_descriptor"]
      user.country = acc["country"]
      user.currency = acc["default_currency"]
      user.stripe_account_id = acc["id"]
      user.stripe_public_key = obj["info"]["stripe_publishable_key"]
      user.stripe_token = obj["credentials"]["token"]
      user.organization = acc["statement_descriptor"]
      user.charge_enabled = acc["charge_enabled"]
      user.save!
    end

    user
  end

  def self.currencies
    [
      {
        currency: 'cad',
        display: 'Canadian Dollar (CAD)'
      },
      {
        currency: 'usd',
        display: 'United States Dollar (USD)'
      }
    ]
  end

  def member(id)
    members.where(:id => id).first
  end

  def membership(id)
    memberships.where(:id => id).first
  end

  def invoice(id)
    usercharges.where(:id => id).first
  end

  def all_invoices
    Invoice.joins(member: [membership: :user]).where(users: {id: id}).order("created_at DESC")
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

  def active_memberships
    memberships.where(archived: false)
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
