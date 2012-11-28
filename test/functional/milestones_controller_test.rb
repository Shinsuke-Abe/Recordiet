# encoding: utf-8
require 'test_helper'

class MilestonesControllerTest < ActionController::TestCase
  fixtures :users, :milestones
  
  def setup
    @john = users(:john)
    @eric = users(:eric)
  end
  
  test "目標入力フォームを開く" do
    assert_open_form :new, @john
  end
  
  test "目標を新規保存する" do
    expected_data = {
      :weight => 64.0,
      :date => Date.today + 60.days,
      :reward => "ケーキバイキング"}
    
    assert_milestone_posted :create, expected_data, @john
  end
  
  test "編集フォームを開く" do
    assert_open_form :edit, @eric
    
    assert_equal milestones(:one), assigns(:milestone)
  end
  
  test "目標を修正する" do
    expected_data = {
      :weight => 54.6,
      :date => Date.today + 90.days,
      :reward => "臨時小遣い"}
    
    assert_milestone_posted :update, expected_data, @eric
  end
  
  private
  def assert_milestone_form_assings
    assert assigns(:current_user)
    assert assigns(:milestone)
  end
  
  def assert_milestone(expected, actual)
    assert_equal expected[:weight], actual.weight
    assert_equal expected[:date], actual.date
    assert_equal expected[:reward], actual.reward
  end
  
  def assert_milestone_posted(action, expected, actual_user)
    session[:id] = actual_user.id
    post action, :milestone => expected
    
    actual_user_milestone = User.find(actual_user.id).milestone
    assert_milestone expected, actual_user_milestone
  end
  
  def assert_open_form(action, user)
    session[:id] = user.id
    get action
    assert_milestone_form_assings
  end
end
