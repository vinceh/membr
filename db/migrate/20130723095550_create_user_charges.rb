class CreateUserCharges < ActiveRecord::Migration
  def up
    create_table(:usercharges) do |t|
      t.integer       :user_id
      t.string        :stripe_charge_id
      t.integer       :amount
      t.integer       :stripe_fee
      t.integer       :number_of_members
      t.timestamps
    end
  end

  def down
    drop_table :usercharges
  end
end
