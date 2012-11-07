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
  
  test "体重履歴は日付の降順にソートされる" do
    eric = users(:eric)
    eric.weight_logs.create(
      :measured_date => Date.yesterday,
      :weight => 69.0
    )
    
    log_added_eric = User.find(users(:eric).id)
    
    assert_equal 3, log_added_eric.weight_logs.length
    assert_equal weight_logs(:two).measured_date, log_added_eric.weight_logs[0].measured_date
    assert_equal weight_logs(:one).measured_date, log_added_eric.weight_logs[1].measured_date
    assert_equal Date.yesterday, log_added_eric.weight_logs[2].measured_date
  end
end
