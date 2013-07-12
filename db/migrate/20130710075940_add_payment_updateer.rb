class AddPaymentUpdateer < ActiveRecord::Migration
  def up
    create_table(:paymenters) do |t|
      t.string        :token
      t.integer       :member_id
      t.timestamps
    end
  end

  def down
    drop_table :paymenters
  end
end
