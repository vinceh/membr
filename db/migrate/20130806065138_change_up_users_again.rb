class ChangeUpUsersAgain < ActiveRecord::Migration
  def change
    remove_column :users, :street_address
    remove_column :users, :city
    remove_column :users, :state
    remove_column :users, :zipcode
    remove_column :users, :phone_number
    remove_column :users, :full_name
    rename_column  :users, :stripe_customer_id, :stripe_account_id

    add_column :users, :stripe_key, :string
    add_column :users, :charge_enabled, :boolean
  end
end
