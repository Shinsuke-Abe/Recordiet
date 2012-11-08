class CreateAchievedMilestoneLogs < ActiveRecord::Migration
  def change
    create_table :achieved_milestone_logs do |t|
      t.date :achieved_date
      t.float :milestone_weight
      t.references :user

      t.timestamps
    end
    add_index :achieved_milestone_logs, :user_id
  end
end
