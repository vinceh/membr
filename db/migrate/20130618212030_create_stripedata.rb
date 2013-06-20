class CreateStripedata < ActiveRecord::Migration
  def up
    create_table(:events) do |t|
      t.string        :token
      t.timestamps
    end
  end

  def down
    drop_table :events
  end
end
