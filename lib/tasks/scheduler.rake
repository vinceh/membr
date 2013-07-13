task :create_member => :environment do
  50.times do
    m = Member.new
    m.developer = true
    m.email = "#{SecureRandom.urlsafe_base64}@gmail.com"
    m.membership = Membership.find(1)
    m.full_name = SecureRandom.urlsafe_base64
    m.phone = "6045615879"
    m.save!
  end
end

# TODO
task :call_page => :environment do
  uri = URI.parse('http://www.membr.herokuapp.com/')
  Net::HTTP.get(uri)
end