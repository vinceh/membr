class AddMoreFieldsToMembers < ActiveRecord::Migration
  def up
    add_column :members, :organization, :string
    add_column :members, :title, :string
    add_column :members, :work_number, :string
  end

  def down
    remove_column :members, :plan_ending_date
    remove_column :members, :title
    remove_column :members, :work_number
  end
end
