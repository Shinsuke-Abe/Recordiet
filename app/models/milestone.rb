class Milestone < ActiveRecord::Base
  belongs_to :user
  attr_accessible :date, :reward, :weight
end
