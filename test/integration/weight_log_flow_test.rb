# encoding: utf-8
require 'test_helper'

class WeightLogFlowTest < ActionDispatch::IntegrationTest
  fixtures :all
  
  test "履歴未登録：ログインすると履歴ページに未登録メッセージを表示する" do
    https!
    show_form_action "/login"
    
    login_action users(:john).mail_address, users(:john).password
    assert_show_user_without_log
  end
  
  test "ユーザ登録が成功する" do
    https!
    show_form_action "/user/new"
    assert assigns(:user)
    
    post_via_redirect "/user", :user => {
      :mail_address => "jimmy@ledzeppelin.com",
      :display_name => "jimmy page",
      :password => "guitar"}
    assert_show_user_without_log
  end
  
  test "履歴登録済：ログインすると履歴ページに一覧を表示する" do
    https!
    login_action users(:eric).mail_address, users(:eric).password
    assert assigns(:user).weight_logs
  end
  
  test "体重履歴を登録する" do
    https!
    login_action users(:john).mail_address, users(:john).password
    assert_show_user_without_log
    
    post_via_redirect "/user/weight_logs/", :weight_log => {
      :measured_date => Date.today - 1,
      :weight => 73.8
    }
    assert_equal "/user", path
    assert !assigns(:user).weight_logs.empty?
  end
  
  test "体重履歴を変更する" do
    https!
    login_action users(:eric).mail_address, users(:eric).password
    
    edit_weight_log_action users(:eric).weight_logs[1], Date.yesterday, 69.0

    assert_equal "/user", path
    assert !assigns(:user).weight_logs.empty?
  end
  
  test "体重履歴を削除する" do
    https!
    login_action users(:eric).mail_address, users(:eric).password
    
    delete_via_redirect "/user/weight_logs/" + users(:eric).weight_logs[0].id.to_s
    assert_equal "/user", path
    assert_equal 1, User.find(users(:eric).id).weight_logs.length
  end
  
  test "体重の変更で未入力エラー" do
    https!
    login_action users(:eric).mail_address, users(:eric).password
    
    edit_weight_log_action users(:eric).weight_logs[1], Date.yesterday, nil
    
    assert_equal "/user/weight_logs/" + users(:eric).weight_logs[1].id.to_s, path
    assert_equal "記録の登録には計測日と体重が必要です。", flash[:notice]
  end
  
  test "目標とご褒美を設定する" do
    https!
    login_action users(:john).mail_address, users(:john).password
    
    create_milestone_action(
      67.0,
      Date.today + 30.days,
      "焼き肉食べ放題")
  end
  
  test "目標を修正する" do
    https!
    login_action users(:eric).mail_address, users(:eric).password
    
    show_form_action "/milestone/edit"
    
    put_via_redirect "/milestone/", :milestone => {
      :weight => 65.0,
      :date => Date.today + 60.days,
      :reward => "ラーメン"
    }
    assert_equal "/user", path
    assert assigns(:user).milestone
  end
  
  test "履歴登録時に目標を達成した場合はメッセージが表示される" do
    https!
    login_action users(:john).mail_address, users(:john).password
    
    create_milestone_action(
      67.5,
      Date.today + 40.days,
      "ホルモン")
    
    assert_show_user_without_log
    post_via_redirect "/user/weight_logs/", :weight_log => {
      :measured_date => Date.today - 1,
      :weight => 67.4
    }
    
    assert_equal "/user", path
    assert_equal(
      "目標を達成しました！おめでとうございます。<br/>ご褒美はホルモンです、楽しんで下さい！",
      flash[:notice])
    assert assigns(:user).achieved_milestone_logs
  end
  
  private
  def assert_show_user_without_log
    assert_equal "履歴が未登録です。", flash[:notice]
  end
  
  def login_action(mail_address, password)
    post_via_redirect "/login", :user => {
      :mail_address => mail_address,
      :password => password
    }
    assert_equal "/user", path
    assert assigns(:user)
  end
  
  def edit_weight_log_action(weight_log, measure_date, weight)
    show_form_action "/user/weight_logs/" + weight_log.id.to_s + "/edit"
    
    put_via_redirect "/user/weight_logs/" + weight_log.id.to_s, :weight_log => {
      :measured_date => measure_date,
      :weight => weight
    }
  end
  
  def create_milestone_action(weight, date, reward)
    show_form_action "/milestone/new"
    
    post_via_redirect "/milestone/", :milestone => {
      :weight => weight,
      :date => date,
      :reward => reward
    }
    assert_equal "/user", path
    assert assigns(:user).milestone
  end
  
  def show_form_action(uri)
    get uri
    assert_response :success
  end
end
