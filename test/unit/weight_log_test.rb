# encoding: utf-8
require 'test_helper'

class WeightLogTest < ActiveSupport::TestCase
  fixtures :users, :weight_logs, :milestones
  
  def setup
    @john = users(:john)
    @eric = users(:eric)
    @create_weight_log = lambda {|arg| WeightLog.new(arg)}
  end
  
  test "日付の入力は必須" do
    assert_validates_invalid @create_weight_log, :weight => 65.1
  end
  
  test "体重の入力は必須" do
    assert_validates_invalid @create_weight_log, :measured_date => Date.yesterday
  end
  
  test "体重は正の実数" do
    assert_validates_invalid(
      @create_weight_log,
      {
        :measured_date => Date.today,
        :weight => -50.5
      })
  end
  
  test "体重履歴は日付の降順にソートされる" do
    @eric.weight_logs.create(
      :measured_date => Date.yesterday,
      :weight => 69.0)
    
    log_added_eric = User.find(@eric.id)
    
    assert_equal 3, log_added_eric.weight_logs.length
    assert_equal weight_logs(:two).measured_date, log_added_eric.weight_logs[0].measured_date
    assert_equal weight_logs(:one).measured_date, log_added_eric.weight_logs[1].measured_date
    assert_equal Date.yesterday, log_added_eric.weight_logs[2].measured_date
  end
  
  # TODO 達成は、体重と合わせてテストケースを書き換える(粒度大きすぎるし、条件色々あるし)
  # TODO 達成履歴に達成した方の数値が入るようにする
  test "新規体重履歴の体重が目標を達成したか判別する" do
    @john.create_milestone(
      :weight => 65.5,
      :date => Date.tomorrow,
      :reward => "寿司")
    
    over_weight_log = @john.weight_logs.create(
      :measured_date => Date.yesterday,
      :weight => 65.6)
    assert !over_weight_log.achieved?
    assert User.find(@john.id).achieved_milestone_logs.empty?
    
    equal_weight_log = @john.weight_logs.create(
      :measured_date => Date.today - 3.days,
      :weight => 65.5)
    assert equal_weight_log.achieved?
    assert_equal 1, User.find(@john.id).achieved_milestone_logs.size
    
    under_weight_log = @john.weight_logs.create(
      :measured_date => Date.today - 8.days,
      :weight => 65.4)
    assert under_weight_log.achieved?
    assert_equal 2, User.find(@john.id).achieved_milestone_logs.size
  end
  
  test "日付はユーザによってユニークになる" do
    @eric.weight_logs.create(
      :measured_date => Date.yesterday,
      :weight => 69.0)
    
    error_new_weight_log = @eric.weight_logs.create(
      :measured_date => Date.yesterday,
      :weight => 63.0)
    assert !error_new_weight_log.errors.empty?
    
    new_weight_log = @john.weight_logs.create(
      :measured_date => Date.today,
      :weight => 63.0)
    assert new_weight_log.errors.empty?
  end
  
  test "体脂肪率を指定して履歴を登録することができる" do
    created_log = @eric.weight_logs.create(
      :measured_date => Date.yesterday,
      :weight => 70.1,
      :fat_percentage => 23.0)
    assert_equal 23.0, created_log.fat_percentage
  end
end
