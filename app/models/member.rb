class Member < ActiveRecord::Base
  belongs_to :membership
  has_many :paymenters
  has_many :invoices

  validates_presence_of :membership_id, :email
  validates_presence_of :full_name, :street_address, :city, :state, :country, :zipcode, :phone, :if => "!developer"
  attr_accessible :membership_id, :full_name, :email, :street_address, :city, :state, :country, :zipcode, :phone, :developer, :paid, :active, :plan_ending_date, :cancel_at_period_end, :organization, :title, :work_number

  def to_json
    {
      id: id,
      active: active,
      full_name: full_name,
      email: email,
      phone: phone,
      joined: created_at.strftime("%b %d, %Y"),
      last_activity: updated_at.strftime("%b %d, %Y"),
      payment: paid,
      payment_time: (paid_time.strftime("%b %d, %Y") if paid_time),
      membership: membership.name,
      plan_ending_date: (plan_ending_date.strftime("%b %d, %Y") if plan_ending_date),
      cancel_at_period_end: cancel_at_period_end
    }
  end

  def self.bulk_invite(file, user)
    require 'iconv'

    book = self.open_spreadsheet(file)
    book.default_sheet = book.sheets.first

    (1..book.last_row).each do |i|
      row = book.row(i)
      email = row[0].strip
      membership = row[1].strip

      membership = Membership.find_by_name(membership)
      if /@/ =~ email && membership && membership.user = user
        creatable = Creatable.new
        creatable.email = email
        creatable.membership_id = membership.id
        creatable.save!

        MemberMailer.send_invite(creatable, request).deliver
      end
    end

    begin
      book = self.open_spreadsheet(file)
      book.default_sheet = book.sheets.first

      (1..book.last_row).each do |i|
        row = book.row(i)
        email = row[0]
        membership = row[1]

        membership = Membership.find_by_name(membership)
        if /@/ =~ email && membership && membership.user = current_user
          creatable = Creatable.new
          creatable.email = email
          creatable.membership_id = membership.id
          creatable.save!

          MemberMailer.send_invite(creatable, request).deliver
        end
      end

      true
    rescue
      false
    end
  end

  def self.open_spreadsheet(file)
    case File.extname(file.original_filename)
      when ".csv" then Roo::Csv.new(file.path, nil, :ignore)
      when ".xls" then Roo::Excel.new(file.path, nil, :ignore)
      when ".xlsx" then Roo::Excelx.new(file.path, nil, :ignore)
      else raise "Unknown file type: #{file.original_filename}"
    end
  end

  def cancel_subscription
    begin
      cu = Stripe::Customer.retrieve(stripe_customer_id)
      res = cu.cancel_subscription(:at_period_end => true)
      if res.cancel_at_period_end
        self.plan_ending_date = Time.at(res.current_period_end)
        self.cancel_at_period_end = true
        save!
        true
      else
        nil
      end
    rescue
      nil
    end
  end

  def change_subscription(membership)
    if (self.active && !self.cancel_at_period_end && membership.id != self.membership_id) || !self.active || self.cancel_at_period_end
      begin
        cu = Stripe::Customer.retrieve(stripe_customer_id)
        res = cu.update_subscription(:plan => membership.id, :prorate => false)
        if res.status == "active"
          self.active = true
          self.cancel_at_period_end = false
          self.plan_ending_date = Time.at(res.current_period_end)
          self.membership = membership
          save!
          return self
        else
          nil
        end
      rescue
        nil
      end
    end
    nil
  end

  def update_payment(token)
    begin
      Stripe.api_key = membership.user.stripe_token
      cu = Stripe::Customer.retrieve(stripe_customer_id)
      cu.card = token
      cu.save

      MemberMailer.payment_updated(self).deliver

      true
    rescue Stripe::CardError => e
      nil
    end
  end

  def join_membership(membership, token)
    begin
      Stripe.api_key = membership.user.stripe_token
      customer = Stripe::Customer.create(
        :card  => token,
        :plan => membership.id,
        :email => email
      )

      self.stripe_customer_id = customer.id
      self.plan_ending_date = Time.at(customer.subscription.current_period_end)
      save

      MemberMailer.joined_membership(self, membership).deliver
      true
    rescue Stripe::CardError => e
      nil
    end
  end

  def self.all_active(user)
    members = user.members

    returnee = []

    if members
      members.each do |m|
        returnee << m.to_json if m.active
      end
    end

    return returnee
  end

  def self.all_inactive(user)
    members = user.members

    returnee = []

    if members
      members.each do |m|
        returnee << m.to_json if !m.active
      end
    end

    return returnee
  end
end