class WeightLog < ActiveRecord::Base
  belongs_to :user
  attr_accessible :measured_date, :weight
end
