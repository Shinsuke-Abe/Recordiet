class AchievedMilestoneLog < ActiveRecord::Base
  belongs_to :user
  attr_accessible :achieved_date, :milestone_weight
end
