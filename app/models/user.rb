require 'bcrypt'

class User < ActiveRecord::Base
  attr_accessor :password
  attr_accessible :display_name, :mail_address, :password_digest, :password
  
  validates :mail_address, :display_name, :presence => true
  validates :mail_address, :uniqueness => true, :email_format => true
  validates :password, :presence => true
  
  has_many :weight_logs, :dependent => :destroy
  has_many :achieved_milestone_logs, :dependent => :destroy
  has_one :milestone, :dependent => :destroy
  
  before_save :encrypt_password
  
  def self.authenticate(mail_address, password)
    if user = User.find_by_mail_address(mail_address)
      user_password = BCrypt::Password.new(user.password_digest)
      
      user_password == password ? user : nil
    else
      user
    end
  end
  
  def encrypt_password
    if password.present?
      self.password_digest = BCrypt::Password.create(password)
    end
  end
end
