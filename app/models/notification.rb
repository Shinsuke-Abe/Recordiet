# encoding: utf-8
class Notification < ActiveRecord::Base
  attr_accessible :content, :end_date, :is_important, :start_date

  validates :content, :presence => true
  validate :start_date_cannot_be_after_end_date

  def display_content
  	if is_important
  		"【重要】" + content
  	else
  		content
  	end
  end

  def self.effective_notification
  	condition = "
  		(start_date IS NULL or start_date <= ?) and
  		(end_date IS NULL or end_date >= ?)
  	"
  	Notification.find(:all, :conditions => [condition, Date.today, Date.today])
  end

  def start_date_cannot_be_after_end_date
  	if start_date and end_date and start_date > end_date
  		errors.add(:start_date, "can't be after end_date")
  	end
  end
end
