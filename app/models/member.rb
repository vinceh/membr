class Member < ActiveRecord::Base
  belongs_to :membership

  validates_presence_of :membership_id, :email
  validates_presence_of :full_name, :street_address, :city, :state, :country, :zipcode, :phone, :if => "!developer"
  attr_accessible :membership_id, :full_name, :email, :street_address, :city, :state, :country, :zipcode, :phone, :developer, :create_token, :claim_date, :paid

  def generate_token
    self.create_token = loop do
      random_token = SecureRandom.urlsafe_base64
      break random_token unless Member.where(create_token: random_token).exists?
    end
  end

  def to_json
    {
      id: id,
      full_name: full_name,
      email: email,
      phone: phone,
      joined: created_at.strftime("%b %m, %Y"),
      payment: paid,
      membership: membership.name
    }
  end

  def self.bulk_invite(file, user)
    require 'iconv'

    book = self.open_spreadsheet(file)
    book.default_sheet = book.sheets.first

    (1..book.last_row).each do |i|
      row = book.row(i)
      email = row[0]
      membership = row[1]

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
end