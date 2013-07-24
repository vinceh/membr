class AddFieldsToUsers < ActiveRecord::Migration
  def up
    add_column :users, :street_address, :string
    add_column :users, :city, :string
    add_column :users, :state, :string
    add_column :users, :country, :string
    add_column :users, :zipcode, :string
    add_column :users, :phone_number, :string
    add_column :users, :stripe_customer_id, :string
  end

  def down
    remove_column :users, :street_address
    remove_column :users, :city
    remove_column :users, :state
    remove_column :users, :country
    remove_column :users, :zipcode
    remove_column :users, :phone_number
    remove_column :users, :stripe_customer_id
  end
end
