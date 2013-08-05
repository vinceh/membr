class Beta < ActiveRecord::Base

  attr_accessible :full_name, :email, :phone_number, :organization,
                  :job_title, :number_of_members, :location, :existing_solution

  validates_presence_of :full_name, :email, :phone_number, :organization,
                        :job_title, :number_of_members, :location

end
