class WeightLog < ActiveRecord::Base
  belongs_to :user
  attr_accessible :measured_date, :weight, :fat_percentage
  
  validates :measured_date, :weight, :presence => true
  validates :weight, :numericality => {greater_than_or_equal_to: 0.1}
  validates :measured_date, :uniqueness => {:scope => :user_id }
  validates :fat_percentage, :numericality => {greater_than_or_equal_to: 0.1}, :allow_blank => true
  
  has_many :menus, :dependent => :destroy
  
  default_scope :order => "measured_date desc"
  
  after_create :create_achieve_log, :if => :achieved?
  
  def self.find_latest_log_has_fat_precentage(user)
    where("user_id = ? and fat_percentage is not null", user.id).first
  end
  
  def achieved?
    weight_milestone_achieved? or fat_percentage_milestone_achieved?
  end
  
  def weight_milestone_achieved?
    user.milestone and
    user.milestone.weight and
    user.milestone.weight >= weight
  end
  
  def fat_percentage_milestone_achieved?
    fat_percentage and
    user.milestone and
    user.milestone.fat_percentage and
    user.milestone.fat_percentage >= fat_percentage
  end
  
  def create_achieve_log
    achieved_log = { :achieved_date => measured_date }
    
    if weight_milestone_achieved?
      achieved_log[:milestone_weight] = user.milestone.weight
    end
    
    if fat_percentage_milestone_achieved?
      achieved_log[:milestone_fat_percentage] = user.milestone.fat_percentage
    end
    
    user.achieved_milestone_logs.create(achieved_log)
  end
end
