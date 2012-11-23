# encoding: utf-8
require 'test_helper'

class WeightLogFlowTest < ActionDispatch::IntegrationTest
  fixtures :all
  
  def setup
    @eric = users(:eric)
    @john = users(:john)
  end
  
  test "履歴登録済：ログインすると履歴ページに一覧を表示する" do
    https!
    login_action(
      :mail_address => @eric.mail_address,
      :password => @eric.password)
    assert assigns(:user).weight_logs
  end
  
  test "体重履歴を登録する" do
    https!
    login_action(
      :mail_address => @john.mail_address,
      :password => @john.password)
    assert_show_user_without_log_and_milestone assigns(:user)
    
    create_weight_log_action(
      :measured_date => Date.today - 1,
      :weight => 73.8)
    
    assert !assigns(:user).weight_logs.empty?
  end
  
  test "体重履歴を変更する" do
    https!
    login_action(
      :mail_address => @eric.mail_address,
      :password => @eric.password)
    
    edit_weight_log_action(
      :weight_log => @eric.weight_logs[1],
      :measured_date => Date.yesterday,
      :weight => 69.0)

    assert_show_user_log
    assert !assigns(:user).weight_logs.empty?
  end
  
  test "体重履歴を削除する" do
    https!
    login_action(
      :mail_address => @eric.mail_address,
      :password => @eric.password)
    
    delete_via_redirect weight_log_path(@eric.weight_logs[0].id)
    
    assert_show_user_log
    assert_equal 1, User.find(@eric.id).weight_logs.length
  end
  
  test "体重の変更で未入力エラー" do
    https!
    login_action(
      :mail_address => @eric.mail_address,
      :password => @eric.password)
    
    edit_weight_log_action(
      :weight_log => @eric.weight_logs[1],
      :measured_date => Date.yesterday,
      :weight => nil)
    
    assert_equal weight_log_path(@eric.weight_logs[1].id), path
  end
  
  test "食事内容を登録する" do
    https!
    login_action(
      :mail_address => @eric.mail_address,
      :password => @eric.password)
    
    erics_weight_log = @eric.weight_logs[0]
    
    create_menu_action(
      :weight_log => erics_weight_log,
      :menu_type => 1,
      :detail => "ご飯\nみそ汁\n納豆")
      
    assert_show_user_log
  end
  
  test "食事内容の登録でエラーが発生した場合はフォームが再表示される" do
    https!
    login_action(
      :mail_address => @eric.mail_address,
      :password => @eric.password)
    
    erics_weight_log = @eric.weight_logs[0]
    
    create_menu_action(
      :weight_log => erics_weight_log,
      :menu_type => 1,
      :detail => nil)
    
    assert_equal weight_log_menus_path(erics_weight_log), path
  end
  
  test "指定した履歴の食事内容を表示できる" do
    https!
    login_action(
      :mail_address => @eric.mail_address,
      :password => @eric.password)
    
    show_form_action weight_log_menus_path(@eric.weight_logs[0])
  end
  
  test "指定した食事内容を変更できる" do
    https!
    login_action(
      :mail_address => @eric.mail_address,
      :password => @eric.password)
    
    erics_weight_log = @eric.weight_logs[0]
    
    edit_menu_action(
      :weight_log => erics_weight_log,
      :menu_id => erics_weight_log.menus[0].id,
      :menu_type => 3,
      :detail => "愛妻弁当")
    
    assert_equal weight_log_menus_path(erics_weight_log), path
  end
  
  test "食事内容の変更でエラーが発生した場合はフォームが再表示される" do
    https!
    login_action(
      :mail_address => @eric.mail_address,
      :password => @eric.password)
    
    erics_weight_log = @eric.weight_logs[0]
    
    edit_menu_action(
      :weight_log => erics_weight_log,
      :menu_id => erics_weight_log.menus[0].id,
      :menu_type => 3,
      :detail => nil)
    
    show_form_action edit_weight_log_menu_path(
      erics_weight_log,
      erics_weight_log.menus[0].id)
  end
  
  test "食事内容を削除する" do
    https!
    login_action(
      :mail_address => @eric.mail_address,
      :password => @eric.password)
    
    erics_weight_log = @eric.weight_logs[0]
    
    show_form_action weight_log_menus_path(erics_weight_log)
    
    delete_via_redirect weight_log_menu_path(
      erics_weight_log,
      erics_weight_log.menus[0].id)
    
    assert_equal weight_log_menus_path(erics_weight_log), path
  end
  
  private
  def edit_weight_log_action(args)
    weight_log = args[:weight_log]
    measure_date = args[:measured_date]
    weight = args[:weight]
    
    show_form_action edit_weight_log_path(weight_log.id)
    
    put_via_redirect weight_log_path(weight_log.id), :weight_log => {
      :measured_date => measure_date,
      :weight => weight
    }
  end
  
  def create_menu_action(args)
    weight_log = args[:weight_log]
    menu_type = args[:menu_type]
    detail = args[:detail]
    show_form_action new_weight_log_menu_path(weight_log)
    
    post_via_redirect weight_log_menus_path(weight_log), :menu => {
      :menu_type => menu_type,
      :detail => detail
    }
  end
  
  def edit_menu_action(args)
    weight_log = args[:weight_log]
    menu_id = args[:menu_id]
    menu_type = args[:menu_type]
    detail = args[:detail]
    
    show_form_action weight_log_menus_path(weight_log)
    show_form_action edit_weight_log_menu_path(weight_log, menu_id)
    
    put_via_redirect weight_log_menu_path(weight_log, menu_id), :menu => {
      :menu_type => menu_type,
      :detail => detail
    }
  end
end
