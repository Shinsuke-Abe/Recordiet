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
    success_login_action user_login_data :john
    
    find(:link, "目標を設定する").click
    
    assert_equal new_milestone_path, current_path, "failures at show create milestone form"
    
    create_milestone_action(
      :weight => 67.0,
      :fat_percentage => 24.0,
      :date => Date.today + 30.days,
      :reward => "焼き肉食べ放題")
    
    assert_equal weight_logs_path, current_path, "failures at create milestone"
    
    find("#milestone_area").has_link? "目標変更"
  end
  
  test "目標の設定でエラーが発生した場合はフォームが再表示される" do
    visit login_path
    success_login_action user_login_data :john
    
    first(:link, "目標を設定する").click
    
    assert_equal new_milestone_path, current_path, "failures at show create milestone form"
    
    create_milestone_action(
      :fat_percentage => 24.0,
      :date => Date.today + 30.days,
      :reward => "焼き肉食べ放題")
    
    assert_equal milestone_path, current_path, "not failures at create milestone"
    
    page.has_css? "help_inline"
  end
  
  test "目標を修正する" do
    visit login_path
    success_login_action user_login_data :eric
    
    first(:link, "目標変更").click
    
    assert_equal edit_milestone_path, current_path, "failures at show edit milestone form"
    
    assert_edit_milestone_form @eric
    
    edit_milestone_action(
      :weight => 65.0,
      :fat_percentage => 24.0,
      :date => Date.today + 60.days,
      :reward => "ラーメン")
    
    assert_equal weight_logs_path, current_path, "failures at update milestone"
  end
  
  test "目標の修正でエラーが発生した場合はフォームが再表示される" do
    visit login_path
    success_login_action user_login_data :eric
    
    first(:link, "目標変更").click
    
    assert_equal edit_milestone_path, current_path, "failures at show edit milestone form"
    
    assert_edit_milestone_form @eric

    edit_milestone_action(
      :weight => nil,
      :fat_percentage => 24.0,
      :date => Date.today + 60.days,
      :reward => "ラーメン")
    
    assert_equal milestone_path, current_path, "not failures at edit milestone"
    page.has_css? "help_inline"
  end
  
  test "履歴登録時に目標を達成した場合はメッセージが表示される" do
    expected_data = {
      :weight => 67.5,
      :date => Date.today + 40.days,
      :reward => "ホルモン"}
    visit login_path
    success_login_action user_login_data :john
    
    first(:link, "目標を設定する").click
    
    assert_equal new_milestone_path, current_path, "failures at show create milestone form"
    
    input_and_post_milestone_action(expected_data, "登録する")
    
    assert_equal weight_logs_path, current_path, "failures at create milestone"
    
    find("#milestone_area").has_link? "目標変更"
    
    assert @john.milestone
    assert @john.achieved_milestone_logs.empty?
    
    select Date.yesterday.year.to_s, :from => "weight_log_measured_date_1i"
    select Date.yesterday.month.to_s + "月", :from => "weight_log_measured_date_2i"
    select Date.yesterday.day.to_s, :from => "weight_log_measured_date_3i"
    fill_in "weight_log_weight", :with => expected_data[:weight] - 0.1
    
    click_button "登録する"
    
    assert_equal weight_logs_path, current_path, "failures at create weight_log"
    
    find("div.alert.alert-success").has_content? sprintf(application_message_for_test(:achieve_milestone), expected_data[:reward])
    
    assert @john.achieved_milestone_logs
  end
  
  test "目標を削除する" do
    visit login_path
    success_login_action user_login_data :eric
    
    first(:link, "目標削除").click
    
    assert_equal weight_logs_path, current_path
    
    find("div.alert.alert-info").find("p").has_content?(
      application_message_for_test(:milestone_not_found))
    find("#milestone_area").has_button? "目標を設定する"
  end
  
  test "目標の達成履歴を表示する" do
    visit login_path
    success_login_action user_login_data :eric
    
    first(:link, "目標達成履歴").click
    
    assert_equal achieved_milestone_logs_path, current_path
  end
  
  private
  def create_milestone_action(input_milestone_data)
    input_and_post_milestone_action input_milestone_data, "登録する"
  end
  
  def edit_milestone_action(input_milestone_data)
    input_and_post_milestone_action input_milestone_data, "更新する"
  end
  
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
  
  def assert_edit_milestone_form(user)
    assert_equal user.milestone.weight.to_s, find_field("milestone_weight").value
    if user.milestone.fat_percentage
      assert_equal user.milestone.fat_percentage.to_s, find_field("milestone_fat_percentage").value
    else
      assert_nil find_field("milestone_fat_percentage").value
    end
    assert_equal user.milestone.date.year.to_s, find_field("milestone_date_1i").value
    assert_equal user.milestone.date.month.to_s, find_field("milestone_date_2i").value
    assert_equal user.milestone.date.day.to_s, find_field("milestone_date_3i").value
    assert_equal user.milestone.reward.to_s, find_field("milestone_reward").value
  end
end
