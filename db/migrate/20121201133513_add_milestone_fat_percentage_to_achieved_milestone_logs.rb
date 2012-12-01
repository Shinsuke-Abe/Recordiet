class AddMilestoneFatPercentageToAchievedMilestoneLogs < ActiveRecord::Migration
  def change
    add_column :achieved_milestone_logs, :milestone_fat_percentage, :float
  end
end
