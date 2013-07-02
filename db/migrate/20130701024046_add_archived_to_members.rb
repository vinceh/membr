class AddArchivedToMembers < ActiveRecord::Migration
  def up
    add_column :members, :active, :boolean, :null => false, :default => true
  end

  def down
    remove_column :members, :active
  end
end
