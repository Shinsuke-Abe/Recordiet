class Milestone < ActiveRecord::Base
  belongs_to :user
  attr_accessible :date, :reward, :weight
  
  validates :weight, :presence => true
  validates :date, :date => {:after_or_equal_to => Date.today}
end
