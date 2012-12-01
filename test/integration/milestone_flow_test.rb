# encoding: utf-8
require 'test_helper'

class MilestoneFlowTest < ActionDispatch::IntegrationTest
  fixtures :all
  
  def setup
    @eric = users(:eric)
    @john = users(:john)
  end
  
  test "目標とご褒美を設定する" do
    https!
    login_action(
      :mail_address => @john.mail_address,
      :password => self.class.user_password(:john))
    
    create_milestone_action(
      :weight => 67.0,
      :date => Date.today + 30.days,
      :reward => "焼き肉食べ放題")
    
    assert_show_user_log
    assert assigns(:current_user).milestone
  end
  
  test "目標の設定でエラーが発生した場合はフォームが再表示される" do
    https!
    login_action(
      :mail_address => @john.mail_address,
      :password => self.class.user_password(:john))
    
    create_milestone_action(
      :weight => nil,
      :date => Date.today + 30.days,
      :reward => "後で交渉")
    
    assert_equal milestone_path, path
  end
  
  test "目標を修正する" do
    https!
    login_action(
      :mail_address => @eric.mail_address,
      :password => self.class.user_password(:eric))
    
    edit_milestone_action(
      :weight => 65.0,
      :date => Date.today + 60.days,
      :reward => "ラーメン")
    
    assert_show_user_log
    assert assigns(:current_user).milestone
  end
  
  test "目標の修正でエラーが発生した場合はフォームが再表示される" do
    https!
    login_action(
      :mail_address => @eric.mail_address,
      :password => self.class.user_password(:eric))
    
    edit_milestone_action(
      :weight => nil,
      :date => Date.today + 60.days,
      :reward => "後で決める")
    
    assert_equal milestone_path, path
  end
  
  # TODO 体重で達成するときと体脂肪率で達成するとき
  test "履歴登録時に目標を達成した場合はメッセージが表示される" do
    expected_data = {
      :weight => 67.5,
      :date => Date.today + 40.days,
      :reward => "ホルモン"}
    https!
    login_action(
      :mail_address => @john.mail_address,
      :password => self.class.user_password(:john))
    
    create_milestone_action expected_data
    
    assert_show_user_log
    assert assigns(:current_user).milestone
    assert assigns(:current_user).achieved_milestone_logs.empty?
    
    create_weight_log_action(
      :measured_date => Date.today - 1,
      :weight => expected_data[:weight] - 0.1)
    
    assert_show_user_log
    assert_equal(
      sprintf(application_message_for_test(:achieve_milestone), expected_data[:reward]),
      flash[:success])
    assert assigns(:current_user).achieved_milestone_logs
  end
  
  test "目標を削除する" do
    https!
    login_action(
      :mail_address => @eric.mail_address,
      :password => self.class.user_password(:eric))
    
    delete_via_redirect milestone_path
    
    assert_equal weight_logs_path, path
  end
  
  test "目標の達成履歴を表示する" do
    https!
    login_action(
      :mail_address => @eric.mail_address,
      :password => self.class.user_password(:eric))
    
    show_form_action achieved_milestone_logs_path
    
    assert !assigns(:achieved_milestone_logs).empty?
  end
  
  private
  def create_milestone_action(args)
    weight = args[:weight]
    date = args[:date]
    reward = args[:reward]
    
    show_form_action new_milestone_path
    
    post_via_redirect milestone_path, :milestone => {
      :weight => weight,
      :date => date,
      :reward => reward
    }
  end
  
  def edit_milestone_action(args)
    weight = args[:weight]
    date = args[:date]
    reward = args[:reward]
    
    show_form_action edit_milestone_path
    
    put_via_redirect milestone_path, :milestone => {
      :weight => weight,
      :date => date,
      :reward => reward
    }
  end
end
