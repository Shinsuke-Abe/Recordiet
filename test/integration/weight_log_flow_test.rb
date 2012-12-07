# encoding: utf-8
require 'test_helper'

class WeightLogFlowTest < ActionDispatch::IntegrationTest
  fixtures :all
  
  def setup
    @eric = users(:eric)
    @john = users(:john)
  end
  
  test "履歴登録済：ログインすると履歴ページに一覧を表示する" do
    visit login_path
    success_login_action user_login_data :eric
    
    assert_equal weight_logs_path, current_path, "failures at login"
    
    table_has_records? @eric.weight_logs.length
  end
  
  test "体重履歴を登録する" do
    expected_logs_length = @eric.weight_logs.length + 1
    
    visit login_path
    success_login_action user_login_data :eric
    
    assert_equal weight_logs_path, current_path, "failures at login"
    
    create_weight_log_action(
      :measured_date => Date.yesterday,
      :weight => 73.8)
    
    click_button "登録する"
    
    table_has_records? expected_logs_length
  end
  
  test "体重履歴を変更する" do
    visit login_path
    success_login_action user_login_data :eric
    
    show_edit_weight_log_form_action 0, @eric.latest_weight_log
    
    edit_weight_log_action(
      :weight => 69.0,
      :measured_date => @eric.latest_weight_log.measured_date)
    
    assert_equal weight_logs_path, current_path
    
    assert_equal 69.0, User.find(@eric.id).latest_weight_log.weight
  end
  
  test "体重履歴を削除する" do
    visit login_path
    success_login_action user_login_data :eric
    
    find("tbody").all("tr")[0].find("a.btn.btn-mini.btn-danger").click
    
    assert_equal weight_logs_path, current_path
    
    eric_log_deleted = User.find(@eric.id)
    
    table_has_records? eric_log_deleted.weight_logs.length
  end
  
  test "体重の変更で未入力エラー" do
    visit login_path
    success_login_action user_login_data :eric
    
    show_edit_weight_log_form_action 0, @eric.latest_weight_log
    
    edit_weight_log_action(
      :weight => nil,
      :measured_date => @eric.latest_weight_log.measured_date)
    
    assert_equal weight_log_path(@eric.latest_weight_log.id), current_path
    has_form_error?
  end
  
  test "食事内容を登録する" do
    visit login_path
    success_login_action user_login_data :eric
    
    find("tbody").all("tr")[0].first(:link, "食事内容追加").click
    
    assert_equal new_weight_log_menu_path(@eric.latest_weight_log), current_path
    
    create_menu_action(
      :menu_type => "朝食",
      :detail => "ご飯\nみそ汁\n納豆")
    
    assert_equal weight_logs_path, current_path
    
    assert find("tbody").all("tr")[0].has_link? "食事内容表示"
    
    find("tbody").all("tr")[0].first(:link, "食事内容表示").click
    
    assert_equal weight_log_menus_path(@eric.latest_weight_log), current_path
    
    table_has_records? @eric.latest_weight_log.menus.length
  end
  
  test "食事内容の登録でエラーが発生した場合はフォームが再表示される" do
    visit login_path
    success_login_action user_login_data :eric
    
    find("tbody").all("tr")[0].first(:link, "食事内容追加").click
    
    assert_equal new_weight_log_menu_path(@eric.latest_weight_log), current_path
    
    create_menu_action(
      :menu_type => "朝食",
      :detail => nil)
    
    assert_equal weight_log_menus_path(@eric.latest_weight_log), current_path
    has_form_error?
  end
  
  test "指定した食事内容を変更できる" do
    visit login_path
    success_login_action user_login_data :eric
    
    find("tbody").all("tr")[0].first(:link, "食事内容表示").click
    
    assert_equal weight_log_menus_path(@eric.latest_weight_log), current_path
    
    show_edit_menu_form 0, @eric.latest_weight_log.menus[0]
    
    edit_menu_action(
      :menu_type => "夕食",
      :detail => "愛妻弁当")
    
    assert_equal weight_log_menus_path(@eric.latest_weight_log), current_path
  end
  
  test "食事内容の変更でエラーが発生した場合はフォームが再表示される" do
    visit login_path
    success_login_action user_login_data :eric
    
    find("tbody").all("tr")[0].first(:link, "食事内容表示").click
    
    assert_equal weight_log_menus_path(@eric.latest_weight_log), current_path
    
    show_edit_menu_form 0, @eric.latest_weight_log.menus[0]
    
    edit_menu_action(
      :menu_type => "夕食",
      :detail => nil)
    
    assert_equal weight_log_menu_path(@eric.latest_weight_log, @eric.latest_weight_log.menus[0].id), current_path
    has_form_error?
  end
  
  test "食事内容を削除する" do
    visit login_path
    success_login_action user_login_data :eric
    
    find("tbody").all("tr")[0].first(:link, "食事内容表示").click
    
    assert_equal weight_log_menus_path(@eric.latest_weight_log), current_path
    
    find("tbody").all("tr")[0].first(:link, "削除").click
    
    assert find("tbody").all("tr").empty?
  end
  
  private
  def show_edit_weight_log_form_action(log_index, weight_log)
    find("tbody").all("tr")[log_index].all("a.btn.btn-mini")[0].click
    
    assert_equal edit_weight_log_path(weight_log.id), current_path
    
    assert_equal weight_log.weight.to_s, find_field("weight_log_weight").value
    if weight_log.fat_percentage
      assert_equal weight_log.fat_percentage.to_s, find_field("weight_log_fat_percentage").value
    else
      assert_nil find_field("weight_log_fat_percentage").value
    end
    assert_equal weight_log.measured_date.year.to_s, find_field("weight_log_measured_date_1i").value
    assert_equal weight_log.measured_date.month.to_s, find_field("weight_log_measured_date_2i").value
    assert_equal weight_log.measured_date.day.to_s, find_field("weight_log_measured_date_3i").value
  end
  
  def edit_weight_log_action(edit_weight_log)
    input_and_post_weight_log_data edit_weight_log, "更新する"
  end
  
  def show_edit_menu_form(menu_index, menu)
    find("tbody").all("tr")[menu_index].first(:link, "変更").click
    
    assert_equal menu.menu_type.to_s, find_field("menu_menu_type").value
    assert_equal menu.detail, find_field("menu_detail").value
  end
  
  def create_menu_action(input_menu)
    input_post_menu_data input_menu, "登録する"
  end
  
  def edit_menu_action(input_menu)
    input_post_menu_data input_menu, "更新する"
  end
  
  def input_post_menu_data(menu_data, button_name)
    select menu_data[:menu_type], :from => "menu_menu_type"
    fill_in "menu_detail", :with => menu_data[:detail]
    
    click_button button_name
  end
end
