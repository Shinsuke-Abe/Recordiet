class Menu < ActiveRecord::Base
  belongs_to :weight_log
  attr_accessible :detail, :menu_type
  
  validates :menu_type, :detail, :presence => true
  validates :menu_type, :inclusion => { :in => 1..5 }
end
