# encoding: utf-8
require 'test_helper'

class MilestonesControllerTest < ActionController::TestCase
  fixtures :users, :milestones
  
  def setup
    @john = users(:john)
    @eric = users(:eric)
  end
  
  test "目標入力フォームを開く" do
    session[:id] = @john
    get :new
    assert_milestone_form_assings
  end
  
  test "目標を新規保存する" do
    expected_data = {
      :weight => 64.0,
      :date => Date.today + 60.days,
      :reward => "ケーキバイキング"}
      
    session[:id] = @john
    post :create, :milestone => expected_data
    
    johns_milestone = User.find(@john.id).milestone
    assert_milestone expected_data, johns_milestone
  end
  
  test "編集フォームを開く" do
    session[:id] = @eric
    get :edit
    assert_milestone_form_assings
    
    assert_equal milestones(:one), assigns(:milestone)
  end
  
  test "目標を修正する" do
    expected_data = {
      :weight => 54.6,
      :date => Date.today + 90.days,
      :reward => "臨時小遣い"}
      
    session[:id] = @eric.id
    post :update, :milestone => expected_data
    
    erics_milestone = User.find(@eric.id).milestone
    assert_milestone expected_data, erics_milestone
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
end
