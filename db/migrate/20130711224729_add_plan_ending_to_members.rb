class AddPlanEndingToMembers < ActiveRecord::Migration
  def up
    add_column :members, :plan_ending_date, :datetime
  end

  def down
    remove_column :members, :plan_ending_date
  end
end
