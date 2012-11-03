class CreateWeightLogs < ActiveRecord::Migration
  def change
    create_table :weight_logs do |t|
      t.date :measured_date
      t.float :weight
      t.references :user

      t.timestamps
    end
    add_index :weight_logs, :user_id
  end
end
