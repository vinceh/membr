class Member < ActiveRecord::Base
  belongs_to :membership

  validates_presence_of :membership_id, :email
  validates_presence_of :full_name, :street_address, :city, :state, :country, :zipcode, :phone, :if => "!developer"
  attr_accessible :membership_id, :full_name, :email, :street_address, :city, :state, :country, :zipcode, :phone, :developer, :paid, :active

  def to_json
    {
      id: id,
      active: active,
      full_name: full_name,
      email: email,
      phone: phone,
      joined: created_at.strftime("%b %m, %Y"),
      last_activity: updated_at.strftime("%b %m, %Y"),
      payment: paid,
      payment_time: (paid_time.strftime("%b %m, %Y") if paid_time),
      membership: membership.name
    }
  end

  def self.all_inactive
    where(:active => false).all
  end

  def self.all_active
    where(:active => true).all
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

        MemberMailer.send_invite(creatable).deliver
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

          MemberMailer.send_invite(creatable).deliver
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
        self.active = false
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
    if (self.active && membership.id != self.membership_id) || !self.active
      begin
        cu = Stripe::Customer.retrieve(stripe_customer_id)
        res = cu.update_subscription(:plan => membership.id, :prorate => false)
        if res.status == "active"
          self.active = true
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
end