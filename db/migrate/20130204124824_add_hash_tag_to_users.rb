class AddHashTagToUsers < ActiveRecord::Migration
  def change
    add_column :users, :hash_tag, :string
  end
end
