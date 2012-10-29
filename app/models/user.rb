class User < ActiveRecord::Base
  attr_accessible :display_name, :mail_address, :password
end
