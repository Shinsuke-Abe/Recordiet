class AddFatPercentageToWeightLogs < ActiveRecord::Migration
  def change
    add_column :weight_logs, :fat_percentage, :float
  end
end
