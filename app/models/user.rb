class User < ActiveRecord::Base
  attr_accessible :display_name, :mail_address, :password
  
  def User.authenticate(mail_address, password)
    User.find(:first, :conditions => {:mail_address => mail_address, :password => password})
  end
end
