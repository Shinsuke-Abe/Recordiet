# encoding: utf-8
require 'test_helper'

class WeightLogTest < ActiveSupport::TestCase
  fixtures :users, :weight_logs
  
  test "日付の入力は必須" do
    new_weight_log = WeightLog.new(
      :weight => 65.1
    )
    assert new_weight_log.invalid?
  end
  
  test "体重の入力は必須" do
    new_weight_log = WeightLog.new(
      :measured_date => Date.yesterday
    )
    assert new_weight_log.invalid?
  end
  
  test "体重は正の実数" do
    new_weight_log = WeightLog.new(
      :measured_date => Date.today,
      :weight => -50.5
    )
    assert new_weight_log.invalid?
  end
  # 日付の入力は必須
  # 体重の入力は必須
  # test "the truth" do
  #   assert true
  # end
end
