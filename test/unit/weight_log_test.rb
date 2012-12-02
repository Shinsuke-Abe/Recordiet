# encoding: utf-8
require 'test_helper'

class WeightLogTest < ActiveSupport::TestCase
  fixtures :users, :weight_logs, :milestones
  
  def setup
    @john = users(:john)
    @eric = users(:eric)
    @test_milestone = {
      :weight => 65.5,
      :fat_percentage => 20.0,
      :date => Date.tomorrow,
      :reward => "寿司"
    }
  end
  
  test "日付の入力は必須" do
    assert_validates_invalid :weight => 65.1 do |arg|
      WeightLog.new(arg)
    end
  end
  
  test "体重の入力は必須" do
    assert_validates_invalid :measured_date => Date.yesterday do |arg|
      WeightLog.new(arg)
    end
  end
  
  test "体重は正の実数" do
    assert_validates_invalid(
      :measured_date => Date.today,
      :weight => -50.5) do |arg|
      WeightLog.new(arg)  
    end
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
  
  test "体重目標も体脂肪率目標も達成してない場合は達成履歴が作成されない" do
    @john.create_milestone(@test_milestone)
    
    @john.weight_logs.create(
      :measured_date => Date.yesterday,
      :weight => 66.0,
      :fat_percentage => 21.0)
    assert User.find(@john.id).achieved_milestone_logs.empty?
  end
  
  test "体重目標を達成した場合は目標体重が記録された達成履歴が作成される" do
    @john.create_milestone(@test_milestone)
    
    @john.weight_logs.create(
      :measured_date => Date.yesterday,
      :weight => 64.9,
      :fat_percentage => 21.0)
    
    achieved_log = User.find(@john.id).achieved_milestone_logs[0]
    assert_equal Date.yesterday, achieved_log.achieved_date
    assert_equal @test_milestone[:weight], achieved_log.milestone_weight
    assert_nil achieved_log.milestone_fat_percentage
  end
  
  test "体脂肪率目標を達成した場合は体脂肪率目標が記録された達成履歴が作成される" do
    @john.create_milestone(@test_milestone)
    
    @john.weight_logs.create(
      :measured_date => Date.yesterday,
      :weight => 70.0,
      :fat_percentage => 19.5)
    
    achieved_log = User.find(@john.id).achieved_milestone_logs[0]
    assert_equal Date.yesterday, achieved_log.achieved_date
    assert_nil achieved_log.milestone_weight
    assert_equal @test_milestone[:fat_percentage], achieved_log.milestone_fat_percentage
  end
  
  test "体重目標と体脂肪率目標を達成した場合は両者が記録された達成履歴が作成される" do
    @john.create_milestone(@test_milestone)
    
    @john.weight_logs.create(
      :measured_date => Date.yesterday,
      :weight => 61.0,
      :fat_percentage => 18.0)
      
    achieved_log = User.find(@john.id).achieved_milestone_logs[0]
    assert_equal Date.yesterday, achieved_log.achieved_date
    assert_equal @test_milestone[:weight], achieved_log.milestone_weight
    assert_equal @test_milestone[:fat_percentage], achieved_log.milestone_fat_percentage
  end
  
  test "目標未設定の場合は達成確認はfalseとなる" do
    added_weight_log = @john.weight_logs.create(
      :measured_date => Date.yesterday,
      :weight => 61.0,
      :fat_percentage => 18.0)
    assert !added_weight_log.achieved?
  end
  
  test "目標設定はあるが体脂肪率目標未設定の場合は体重未達成でfalseとなる" do
    @john.create_milestone(
      :weight => 65.5,
      :date => Date.tomorrow,
      :reward => "寿司")
    
    added_weight_log = @john.weight_logs.create(
      :measured_date => Date.yesterday,
      :weight => 66.0,
      :fat_percentage => 18.0)
    assert !added_weight_log.achieved?
  end
  
  test "体重目標達成の境界値テスト" do
    @john.create_milestone(@test_milestone)
    
    over_weight_log = @john.weight_logs.create(
      :measured_date => Date.yesterday,
      :weight => 65.6)
    assert !over_weight_log.achieved?
    
    equal_weight_log = @john.weight_logs.create(
      :measured_date => Date.today - 3.days,
      :weight => 65.5)
    assert equal_weight_log.achieved?
  end
  
  test "体脂肪率目標達成の境界値テスト" do
    @john.create_milestone(@test_milestone)
    
    over_weight_log = @john.weight_logs.create(
      :measured_date => Date.yesterday,
      :weight => 66,
      :fat_percentage => 20.1)
    assert !over_weight_log.achieved?
    
    equal_weight_log = @john.weight_logs.create(
      :measured_date => Date.today - 3.days,
      :weight => 66,
      :fat_percentage => 20.0)
    assert equal_weight_log.achieved?
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
