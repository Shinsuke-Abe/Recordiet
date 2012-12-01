class Milestone < ActiveRecord::Base
  belongs_to :user
  attr_accessible :date, :reward, :weight, :fat_percentage
  
  validates :weight, :presence => true, :numericality => {greater_than_or_equal_to: 0.1}
  validates :date, :date => {:after_or_equal_to => Date.today}
  validates :fat_percentage, :numericality => {greater_than_or_equal_to: 0.1}, :allow_blank => true
end
