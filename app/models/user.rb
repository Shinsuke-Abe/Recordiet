class User < ActiveRecord::Base
  attr_accessible :display_name, :mail_address, :password
  
  validates :mail_address, :display_name, :password, :presence => true
  validates :mail_address, :uniqueness => true, :email_format => true
  
  has_many :weight_logs, :dependent => :destroy
  has_many :achieved_milestone_logs, :dependent => :destroy
  has_one :milestone, :dependent => :destroy
  
  def User.authenticate(mail_address, password)
    User.find(:first, :conditions => {:mail_address => mail_address, :password => password})
  end
end
