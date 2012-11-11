class Menu < ActiveRecord::Base
  belongs_to :weight_log
  attr_accessible :detail, :type
end
