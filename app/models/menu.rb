class Menu < ActiveRecord::Base
  belongs_to :weight_log
  attr_accessible :detail, :type
  
  validates :type, :detail, :presence => true
  validates :type, :inclusion => { :in => 1..5 }
end
