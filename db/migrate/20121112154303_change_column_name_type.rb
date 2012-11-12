class ChangeColumnNameType < ActiveRecord::Migration
  def up
  end

  def down
  end
  
  def change
    rename_column :menus, :type, :menu_type
  end
end
