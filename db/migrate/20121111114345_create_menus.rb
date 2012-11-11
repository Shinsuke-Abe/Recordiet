class CreateMenus < ActiveRecord::Migration
  def change
    create_table :menus do |t|
      t.integer :type
      t.text :detail
      t.references :weight_log

      t.timestamps
    end
    add_index :menus, :weight_log_id
  end
end
