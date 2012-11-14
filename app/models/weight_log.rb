class WeightLog < ActiveRecord::Base
  belongs_to :user
  attr_accessible :measured_date, :weight
  
  validates :measured_date, :weight, presence: true
  validates :weight, numericality: {greater_than_or_equal_to: 0.1}
  
  has_many :menus, :dependent => :destroy
  
  default_scope :order => "measured_date desc"
end
