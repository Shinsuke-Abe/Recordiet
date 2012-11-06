class CreateMilestones < ActiveRecord::Migration
  def change
    create_table :milestones do |t|
      t.float :weight
      t.date :date
      t.text :reward
      t.references :user

      t.timestamps
    end
    add_index :milestones, :user_id
  end
end
