class Milestone < ActiveRecord::Base
  belongs_to :user
  attr_accessible :date, :reward, :weight
  
  validates :weight, :presence => true
end
