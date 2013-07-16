class CreateInvoice < ActiveRecord::Migration
  def up
    create_table(:invoices) do |t|
      t.integer       :membership_id
      t.string        :stripe_charge_id
      t.integer       :amount
      t.integer       :stripe_fee
      t.boolean       :paid_out, default: false
      t.timestamps
    end
  end

  def down
    drop_table :invoices
  end
end