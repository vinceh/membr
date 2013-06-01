class CreateMember < ActiveRecord::Migration
  def up
    create_table(:member) do |t|
      t.integer       :membership_id
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

    add_column(:member, :data, :json)
  end

  def down
    drop_table :member
  end
end
