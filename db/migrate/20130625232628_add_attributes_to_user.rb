class AddAttributesToUser < ActiveRecord::Migration
  def up
    add_column :users, :full_name, :string, :null => false, :default => ""
    add_column :users, :organization, :string, :null => false, :default => ""
  end

  def down
    remove_column :users, :full_name
    remove_column :users, :organization
  end
end
