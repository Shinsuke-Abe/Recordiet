class CreateTwitterLinks < ActiveRecord::Migration
  def change
    create_table :twitter_links do |t|
      t.string :consumer_key
      t.string :consumer_secret

      t.timestamps
    end
  end
end
