# encoding: utf-8
require 'test_helper'

class MilestoneTest < ActiveSupport::TestCase
  fixtures :users, :milestones
  
  test "目標体重の入力は必須" do
    new_milestone = Milestone.new(
      :date => Date.tomorrow,
      :reward => "旅行")
    assert new_milestone.invalid?
  end
end
