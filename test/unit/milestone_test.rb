# encoding: utf-8
require 'test_helper'

class MilestoneTest < ActiveSupport::TestCase
  fixtures :users, :milestones, :weight_logs
  
  test "目標体重の入力は必須" do
    assert_validates_invalid(
      :date => Date.tomorrow,
      :reward => "旅行") do |arg|
      Milestone.new(arg)
    end
  end
  
  test "期限は未来(本日以降)のみ指定可能" do
    assert_validates_invalid(
      :weight => 71.2,
      :date => Date.today - 4.days,
      :reward => "デート") do |arg|
      Milestone.new(arg)
    end
  end
end
