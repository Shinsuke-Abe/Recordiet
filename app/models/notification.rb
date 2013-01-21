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

  def is_expired
    end_date and end_date < Date.today
  end

  def self.effective_notification
  	condition = "
  		(start_date IS NULL or start_date <= ?) and
  		(end_date IS NULL or end_date >= ?)
  	"
  	Notification.find(:all, :conditions => [condition, Date.today, Date.today])
  end

  def self.join_effective_notification
    effective = Notification.effective_notification

    effective.map{|notification| notification.display_content}.join("\n") if effective.present?
  end

  def start_date_cannot_be_after_end_date
  	if start_date and end_date and start_date > end_date
  		errors.add(:start_date, "can't be after end_date")
  	end
  end
end
