class CreateBeta < ActiveRecord::Migration
  def up
    create_table(:beta) do |t|
      t.string       :full_name
      t.string       :email
      t.string       :phone_number
      t.string       :organization
      t.string       :job_title
      t.integer      :number_of_members
      t.string       :location
      t.string       :existing_solution
      t.timestamps
    end
  end

  def down
    drop_table(:beta)
  end
end
