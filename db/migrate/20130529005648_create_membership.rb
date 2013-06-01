class CreateMembership < ActiveRecord::Migration
  def up
    create_table(:memberships) do |t|
      t.integer       :user_id
      t.string        :name
      t.boolean       :is_private
      t.integer       :fee
      t.string        :renewal_period
      t.timestamps
    end
  end

  def down
    drop_table :memberships
  end
end
