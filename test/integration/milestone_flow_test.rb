# encoding: utf-8
require 'test_helper'

class MilestoneFlowTest < ActionDispatch::IntegrationTest
  fixtures :all
  
  def setup
    @eric = users(:eric)
    @john = users(:john)
  end
  
  test "目標とご褒美を設定する" do
    visit login_path
    success_login_action(
      :mail_address => @john.mail_address,
      :password => self.class.user_password(:john),
      :display_name => @john.display_name)
    
    find(:link, "目標を設定する").click
    
    assert_equal new_milestone_path, current_path, "failures at show create milestone form"
    
    input_and_post_milestone_action({
      :weight => 67.0,
      :fat_percentage => 24.0,
      :date => Date.today + 30.days,
      :reward => "焼き肉食べ放題"
    }, "登録する")
    
    assert_equal weight_logs_path, current_path, "failures at create milestone"
    
    find("#milestone_area").has_link? "目標変更"
  end
  
  test "目標の設定でエラーが発生した場合はフォームが再表示される" do
    visit login_path
    success_login_action(
      :mail_address => @john.mail_address,
      :password => self.class.user_password(:john),
      :display => @john.display_name)
    
    first(:link, "目標を設定する").click
    
    assert_equal new_milestone_path, current_path, "failures at show create milestone form"
    
    input_and_post_milestone_action({
      :fat_percentage => 24.0,
      :date => Date.today + 30.days,
      :reward => "焼き肉食べ放題"
    }, "登録する")
    
    assert_equal milestone_path, current_path, "not failures at create milestone"
    
    page.has_css? "help_inline"
  end
  
  test "目標を修正する" do
    visit login_path
    success_login_action(
      :mail_address => @eric.mail_address,
      :password => self.class.user_password(:eric),
      :display_name => @eric.display_name)
    
    first(:link, "目標変更").click
    
    assert_equal edit_milestone_path, current_path, "failures at show edit milestone form"
    
    assert_equal @eric.milestone.weight.to_s, find_field("milestone_weight").value
    assert_nil find_field("milestone_fat_percentage").value
    assert_equal @eric.milestone.date.year.to_s, find_field("milestone_date_1i").value
    assert_equal @eric.milestone.date.month.to_s, find_field("milestone_date_2i").value
    assert_equal @eric.milestone.date.day.to_s, find_field("milestone_date_3i").value
    assert_equal @eric.milestone.reward, find_field("milestone_reward").value
    
    input_and_post_milestone_action({
      :weight => 65.0,
      :fat_percentage => 24.0,
      :date => Date.today + 60.days,
      :reward => "ラーメン"
    }, "更新する")
    
    assert_equal weight_logs_path, current_path, "failures at update milestone"
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
  def input_and_post_milestone_action(input_milestone_data, button_name)
    fill_in "milestone_weight", :with => input_milestone_data[:weight]
    fill_in "milestone_fat_percentage", :with => input_milestone_data[:fat_percentage]
    if input_milestone_data[:date]
      select input_milestone_data[:date].year.to_s, :from => "milestone_date_1i"
      select input_milestone_data[:date].month.to_s + "月", :from => "milestone_date_2i"
      select input_milestone_data[:date].day.to_s, :from => "milestone_date_3i"
    end
    fill_in "milestone_reward", :with => input_milestone_data[:reward]
    
    click_button button_name
  end
  
  # for test::unit
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
