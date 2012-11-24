class User < ActiveRecord::Base
  attr_accessor :password
  attr_accessible :display_name, :mail_address, :password_digest, :password
  
  validates :mail_address, :display_name, :presence => true
  validates :mail_address, :uniqueness => true, :email_format => true
  validates :password, :presence => true, :on => :create
  
  has_many :weight_logs, :dependent => :destroy
  has_many :achieved_milestone_logs, :dependent => :destroy
  has_one :milestone, :dependent => :destroy
  
  before_save :encrypt_password
  
  def User.authenticate(mail_address, password)
    User.find(:first, :conditions => {:mail_address => mail_address, :password_digest => password})
  end
  
  def encrypt_password
    if password.present?
      self.password_digest = password
    end
  end
end
