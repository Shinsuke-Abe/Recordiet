class AddTwitterLinkFlagToUsers < ActiveRecord::Migration
  def change
    add_column :users, :twitter_link_flag, :boolean
  end
end
