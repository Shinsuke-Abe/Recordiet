# encoding : utf-8
class Milestone < ActiveRecord::Base
  belongs_to :user
  attr_accessible :date, :reward, :weight, :fat_percentage

  validates :weight, :presence => true, :numericality => {greater_than_or_equal_to: 0.1}
  validates :date, :date => {:after_or_equal_to => Date.today}, :allow_blank => true
  validates :fat_percentage, :numericality => {greater_than_or_equal_to: 0.1}, :allow_blank => true

  def achieve_message
    "目標を達成しました！おめでとうございます。\nご褒美は#{reward}です、楽しんで下さい！"
  end
end
