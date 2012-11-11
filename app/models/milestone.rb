class Milestone < ActiveRecord::Base
  belongs_to :user
  attr_accessible :date, :reward, :weight
  
  validates :weight, :presence => true
  validates :date, :date => {:after_or_equal_to => Date.today}
  
  def achieve?(weight_log)
    if weight_log and
      weight_log.weight and
      weight_log.weight <= weight
      true
    else
      false
    end
  end
end
