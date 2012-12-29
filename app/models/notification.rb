class Notification < ActiveRecord::Base
  attr_accessible :content, :end_date, :is_important, :start_date
end
