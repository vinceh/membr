class CreateTokens < ActiveRecord::Migration
  def up
    create_table(:creatables) do |t|
      t.string        :token
      t.timestamps
    end
  end

  def down
    drop_table :creatables
  end
end
