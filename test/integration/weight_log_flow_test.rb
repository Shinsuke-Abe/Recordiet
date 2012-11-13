# encoding: utf-8
require 'test_helper'

class WeightLogFlowTest < ActionDispatch::IntegrationTest
  include WeightLogsHelper
  fixtures :all
  
  def setup
    @eric = users(:eric)
    @john = users(:john)
  end
  
  test "履歴未登録：ログインすると履歴ページに未登録メッセージを表示する" do
    https!
    show_form_action login_path
    
    login_action @john.mail_address, @john.password
    assert_show_user_without_log
  end
  
  test "ユーザ登録が成功する" do
    https!
    show_form_action new_user_path
    assert assigns(:user)
    
    post_via_redirect user_path, :user => {
      :mail_address => "jimmy@ledzeppelin.com",
      :display_name => "jimmy page",
      :password => "guitar"}
    assert_show_user_without_log
  end
  
  test "履歴登録済：ログインすると履歴ページに一覧を表示する" do
    https!
    login_action @eric.mail_address, @eric.password
    assert assigns(:user).weight_logs
  end
  
  test "体重履歴を登録する" do
    https!
    login_action @john.mail_address, @john.password
    assert_show_user_without_log
    
    create_weight_log_action(Date.today - 1, 73.8)
    
    assert !assigns(:user).weight_logs.empty?
  end
  
  test "体重履歴を変更する" do
    https!
    login_action @eric.mail_address, @eric.password
    
    edit_weight_log_action @eric.weight_logs[1], Date.yesterday, 69.0

    assert_show_user_log
    assert !assigns(:user).weight_logs.empty?
  end
  
  test "体重履歴を削除する" do
    https!
    login_action @eric.mail_address, @eric.password
    
    delete_via_redirect weight_log_path(@eric.weight_logs[0].id)
    
    assert_show_user_log
    assert_equal 1, User.find(@eric.id).weight_logs.length
  end
  
  test "体重の変更で未入力エラー" do
    https!
    login_action @eric.mail_address, @eric.password
    
    edit_weight_log_action @eric.weight_logs[1], Date.yesterday, nil
    
    assert_equal weight_log_path(@eric.weight_logs[1].id), path
  end
  
  test "目標とご褒美を設定する" do
    https!
    login_action @john.mail_address, @john.password
    
    create_milestone_action(67.0, Date.today + 30.days, "焼き肉食べ放題")
    
    assert_show_user_log
    assert assigns(:user).milestone
  end
  
  test "目標の設定でエラーが発生した場合はフォームが再表示される" do
    https!
    login_action @john.mail_address, @john.password
    
    create_milestone_action(nil, Date.today + 30.days, "後で交渉")
    
    assert_equal milestone_path, path
  end
  
  test "目標を修正する" do
    https!
    login_action @eric.mail_address, @eric.password
    
    edit_milestone_action(65.0, Date.today + 60.days, "ラーメン")
    
    assert_show_user_log
    assert assigns(:user).milestone
  end
  
  test "目標の修正でエラーが発生した場合はフォームが再表示される" do
    https!
    login_action @eric.mail_address, @eric.password
    
    edit_milestone_action(nil, Date.today + 60.days, "後で決める")
    
    assert_equal milestone_path, path
  end
  
  test "履歴登録時に目標を達成した場合はメッセージが表示される" do
    https!
    login_action @john.mail_address, @john.password
    
    create_milestone_action(67.5, Date.today + 40.days, "ホルモン")
    
    assert_show_user_log
    assert assigns(:user).milestone
    
    assert_show_user_without_log
    create_weight_log_action(Date.today - 1, 67.4)
    
    assert_show_user_log
    assert_equal(
      achieve_message("ホルモン"),
      flash[:notice])
    assert assigns(:user).achieved_milestone_logs
  end
  
  test "目標の達成履歴を表示する" do
    https!
    login_action @eric.mail_address, @eric.password
    
    show_form_action achieved_milestone_logs_path
    
    assert !assigns(:achieved_milestone_logs).empty?
  end
  
  test "未ログインユーザにアクセス制御をかける" do
    https!
    # weight_logs_controllerは全メソッド
    required_login_filtered weight_logs_path
    required_login_filtered edit_weight_log_path(@john.id)
    
    # milestones_controllerは全メソッド
    required_login_filtered new_milestone_path
    required_login_filtered edit_milestone_path
    
    # achieved_milestone_logs_controllerは全メソッド
    required_login_filtered achieved_milestone_logs_path
    
    # TODO user_controllerは編集と削除が加わったときにアクセス制御を行う
  end
  
  test "ログアウトする" do
    https!
    login_action @eric.mail_address, @eric.password
    
    delete_via_redirect login_path
    assert_equal login_path, path
    
    required_login_filtered weight_logs_path
  end
  
  test "食事内容を登録する" do
    https!
    login_action @eric.mail_address, @eric.password
    
    erics_weight_log = @eric.weight_logs[0]
    
    create_menu_action(
      erics_weight_log,
      1,
      "ご飯
      みそ汁
      納豆")
      
    assert_show_user_log
  end
  
  test "食事内容の登録でエラーが発生した場合はフォームが再表示される" do
    https!
    login_action @eric.mail_address, @eric.password
    
    erics_weight_log = @eric.weight_logs[0]
    
    create_menu_action(erics_weight_log, 1, nil)
    
    assert_equal weight_log_menus_path(erics_weight_log), path
  end
  
  test "指定した履歴の食事内容を表示できる" do
    https!
    login_action @eric.mail_address, @eric.password
    
    show_form_action weight_log_menus_path(@eric.weight_logs[0])
  end
  
  test "指定した食事内容を変更できる" do
    https!
    login_action @eric.mail_address, @eric.password
    
    erics_weight_log = @eric.weight_logs[0]
    
    edit_menu_action(erics_weight_log, erics_weight_log.menus[0].id, 3, "愛妻弁当")
    
    assert_equal weight_log_menus_path(erics_weight_log), path
  end
  
  test "食事内容の変更でエラーが発生した場合はフォームが再表示される" do
    https!
    login_action @eric.mail_address, @eric.password
    
    erics_weight_log = @eric.weight_logs[0]
    
    edit_menu_action(erics_weight_log, erics_weight_log.menus[0].id, 3, nil)
    
    show_form_action edit_weight_log_menu_path(
      erics_weight_log,
      erics_weight_log.menus[0].id)
  end
  
  private
  def assert_show_user_log
    assert_equal weight_logs_path, path
    assert assigns(:user)
  end
  
  def assert_show_user_without_log
    assert_equal WeightLogsHelper::WEIGHT_LOG_NOT_FOUND, flash[:notice]
  end
  
  def login_action(mail_address, password)
    post_via_redirect login_path, :user => {
      :mail_address => mail_address,
      :password => password
    }
    assert_show_user_log
  end
  
  def create_weight_log_action(measure_date, weight)
    post_via_redirect weight_logs_path, :weight_log => {
      :measured_date => measure_date,
      :weight => weight
    }
    assert_show_user_log
  end
  
  def edit_weight_log_action(weight_log, measure_date, weight)
    show_form_action edit_weight_log_path(weight_log.id)
    
    put_via_redirect weight_log_path(weight_log.id), :weight_log => {
      :measured_date => measure_date,
      :weight => weight
    }
  end
  
  def create_milestone_action(weight, date, reward)
    show_form_action new_milestone_path
    
    post_via_redirect milestone_path, :milestone => {
      :weight => weight,
      :date => date,
      :reward => reward
    }
  end
  
  def edit_milestone_action(weight, date, reward)
    show_form_action edit_milestone_path
    
    put_via_redirect milestone_path, :milestone => {
      :weight => weight,
      :date => date,
      :reward => reward
    }
  end
  
  def create_menu_action(weight_log, menu_type, detail)
    show_form_action new_weight_log_menu_path(weight_log)
    
    post_via_redirect weight_log_menus_path(weight_log), :menu => {
      :menu_type => menu_type,
      :detail => detail
    }
  end
  
  def edit_menu_action(weight_log, menu_id, menu_type, detail)
    show_form_action weight_log_menus_path(weight_log)
    show_form_action edit_weight_log_menu_path(weight_log, menu_id)
    
    put_via_redirect weight_log_menu_path(weight_log, menu_id), :menu => {
        :menu_type => menu_type,
        :detail => detail
      }
  end
  
  def show_form_action(uri)
    get uri
    assert_response :success
  end
  
  def required_login_filtered(uri)
    get uri
    assert login_path, path
  end
end
