class AddCancelledToMembers < ActiveRecord::Migration
  def up
    add_column :members, :cancel_at_period_end, :boolean, :default => false
  end

  def down
    remove_column :members, :cancel_at_period_end
  end
end
