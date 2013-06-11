class CreateMember < ActiveRecord::Migration
  def up
    create_table(:members) do |t|
      t.integer       :membership_id
      t.string        :email
      t.string        :full_name
      t.string        :street_address
      t.string        :city
      t.string        :state
      t.string        :country
      t.string        :zipcode
      t.string        :phone
      t.boolean       :developer
      t.timestamps
    end
  end

  def down
    drop_table :members
  end
end
