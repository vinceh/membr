class ChangeUpUsersAgain2 < ActiveRecord::Migration
  def change

    rename_column  :users, :stripe_key, :stripe_public_key
    add_column :users, :stripe_token, :string
  end
end
