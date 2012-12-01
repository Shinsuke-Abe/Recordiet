class AddFatPercentageToMilestones < ActiveRecord::Migration
  def change
    add_column :milestones, :fat_percentage, :float
  end
end
