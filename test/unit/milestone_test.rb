# encoding: utf-8
require 'test_helper'

class MilestoneTest < ActiveSupport::TestCase
  fixtures :users, :milestones, :weight_logs
  
  test "目標体重の入力は必須" do
    new_milestone = Milestone.new(
      :date => Date.tomorrow,
      :reward => "旅行")
    assert new_milestone.invalid?
  end
  
  test "期限は未来(本日以降)のみ指定可能" do
    new_milestone = Milestone.new(
      :weight => 71.2,
      :date => Date.yesterday,
      :reward => "デート")
    assert new_milestone.invalid?
  end
  
  test "新規体重履歴が目標を達成したか判別する" do
    target_milestone = Milestone.new(
      :weight => 65.5,
      :date => Date.tomorrow,
      :reward => "寿司"
    )
    
    over_weight_log = WeightLog.new(
      :measured_date => Date.yesterday,
      :weight => 65.6)
    
    equal_weight_log = WeightLog.new(
      :measured_date => Date.today - 3.days,
      :weight => 65.5)
    
    under_weight_log = WeightLog.new(
      :measured_date => Date.today - 2.days,
      :weight => 65.4)
    
    assert !target_milestone.achieve?(over_weight_log)
    assert target_milestone.achieve?(equal_weight_log)
    assert target_milestone.achieve?(under_weight_log)
  end
end
