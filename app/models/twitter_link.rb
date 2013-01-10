class TwitterLink < ActiveRecord::Base
  attr_accessible :consumer_key, :consumer_secret

  validates :consumer_key, :presence => true
end
