class User < ActiveRecord::Base
  attr_accessible :display_name, :mail_address, :password
  
  validates :mail_address, :display_name, :password, :presence => true
  
  has_many :weight_logs
  has_many :achieved_milestone_logs
  has_one :milestone
  
  def User.authenticate(mail_address, password)
    User.find(:first, :conditions => {:mail_address => mail_address, :password => password})
  end
end
