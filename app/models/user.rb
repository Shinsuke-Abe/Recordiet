require 'bcrypt'

class User < ActiveRecord::Base
  attr_accessor :password
  attr_accessible :display_name, :mail_address, :password_digest, :password
  
  validates :mail_address, :display_name, :password, :presence => true
  validates :mail_address, :uniqueness => true, :email_format => true
  
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
  
  def latest_weight_log
    weight_logs.first
  end
  
  def latest_weight_log_has_fat_percentage
    WeightLog.find_latest_log_has_fat_precentage(self)
  end
  
  def weight_to_milestone
    if milestone and milestone.weight and latest_weight_log
      (latest_weight_log.weight - milestone.weight).round(2)
    end
  end
  
  def days_to_milestone
    if milestone and milestone.weight
      (milestone.date - Date.today).to_i
    end
  end
  
  def fat_percentage_to_milestone
    if milestone and milestone.fat_percentage and latest_weight_log_has_fat_percentage
      (latest_weight_log_has_fat_percentage.fat_percentage - milestone.fat_percentage).round(2)
    end
  end
end
