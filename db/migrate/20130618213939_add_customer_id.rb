class AddCustomerId < ActiveRecord::Migration
  def up
    add_column :members, :stripe_customer_id, :string
    add_column :members, :paid, :boolean, :default => false
    add_column :members, :paid_time, :datetime
  end

  def down
    remove_column :members, :stripe_customer_id
    remove_column :members, :paid
    remove_column :members, :paid_time
  end
end
