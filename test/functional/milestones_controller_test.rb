# encoding: utf-8
require 'test_helper'

class MilestonesControllerTest < ActionController::TestCase
  fixtures :users, :milestones
  
  test "目標入力フォームを開く" do
    session[:id] = users(:john)
    get :new
    assigns(:user)
    assigns(:milestone)
  end
  
  test "目標を新規保存する" do
    session[:id] = users(:john)
    post :create, :milestone => {
      :weight => 64.0,
      :date => Date.today + 60.days,
      :reward => "ケーキバイキング"}
    
    johns_milestone = User.find(users(:john).id).milestone
    assert_equal 64.0, johns_milestone.weight
    assert_equal Date.today + 60.days, johns_milestone.date
    assert_equal "ケーキバイキング", johns_milestone.reward
  end
  
  test "編集フォームを開く" do
    session[:id] = users(:eric)
    get :edit
    assigns(:user)
    assigns(:milestone)
    
    assert_equal milestones(:one), assigns(:milestone)
  end
  
  test "目標を修正する" do
    session[:id] = users(:eric)
    post :update, :milestone => {
        :weight => 54.6,
        :date => Date.today + 90.days,
        :reward => "臨時小遣い"}
    
    erics_milestone = User.find(users(:eric).id).milestone
    assert_equal 54.6, erics_milestone.weight
    assert_equal Date.today + 90.days, erics_milestone.date
    assert_equal "臨時小遣い", erics_milestone.reward
  end
end
