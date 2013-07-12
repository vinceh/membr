class AddActiveToMemberships < ActiveRecord::Migration
  def up
    add_column :memberships, :archived, :boolean, :null => false, :default => false
  end

  def down
    remove_column :memberships, :archived
  end
end
