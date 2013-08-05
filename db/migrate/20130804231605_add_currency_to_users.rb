class AddCurrencyToUsers < ActiveRecord::Migration
  def up
    add_column :users, :currency, :string
  end

  def down
    remove_column :users, :currency
  end
end
