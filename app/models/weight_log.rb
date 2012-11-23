class WeightLog < ActiveRecord::Base
  belongs_to :user
  attr_accessible :measured_date, :weight
  
  validates :measured_date, :weight, presence: true
  validates :weight, numericality: {greater_than_or_equal_to: 0.1}
  validates :measured_date, :uniqueness => {:scope => :user_id }
  
  has_many :menus, :dependent => :destroy
  
  default_scope :order => "measured_date desc"
  
  after_create :create_achieve_log, :if => :achieved?
  
  def achieved?
    if user.milestone and
      user.milestone.weight and
      user.milestone.weight >= weight
      true
    else
      false
    end
  end
  
  def create_achieve_log
    user.achieved_milestone_logs.create(
      :achieved_date => measured_date,
      :milestone_weight => user.milestone.weight)
  end
end
