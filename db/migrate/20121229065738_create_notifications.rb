class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.date :start_date
      t.date :end_date
      t.boolean :is_important
      t.text :content

      t.timestamps
    end
  end
end
