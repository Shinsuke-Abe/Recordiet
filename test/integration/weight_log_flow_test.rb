# encoding: utf-8
require 'test_helper'

class WeightLogFlowTest < ActionDispatch::IntegrationTest
  fixtures :all
  
  test "履歴未登録：ログインすると履歴ページに未登録メッセージを表示する" do
    https!
    get "/login"
    assert_response :success
    
    login_action users(:john).mail_address, users(:john).password
    assert_show_user_without_log
  end
  
  test "ユーザ登録が成功する" do
    https!
    get "/user/new"
    assert_response :success
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
    assert_equal "/user", path
    assert assigns(:user)
    assert assigns(:user).weight_logs
  end
  
  test "体重履歴を登録する" do
    https!
    login_action users(:john).mail_address, users(:john).password
    
    assert_equal "/user", path
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
    
    get "/user/milestone/new"
    assert_response :success
    
    post_via_redirect "/user/milestone", :milestone => {
      :weight => 67.0,
      :date => Date.today + 30.days,
      :reward => "焼き肉食べ放題"
    }
    assert_equal "/user", path
    assert assigns(:user).milestone
  end
  
  test "目標を修正する" do
    https!
    login_action users(:eric).mail_address, users(:eric).password
    
    get "/user/milestone/edit"
    assert_response :success
    
    put_via_redirect "/user/milestone/", :milestone => {
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
    
    get "/user/milestone/new"
    assert_response :success
    
    post_via_redirect "/user/milestone/", :milestone => {
      :weight => 67.5,
      :date => Date.today + 40.days,
      :reward => "ホルモン"
    }
    assert_equal "/user", path
    
    post_via_redirect "/user/weight_logs/", :weight_log => {
      :measured_date => Date.yesterday,
      :weight => 67.4
    }
    
    assert_equal "/user", path
    assert_equal(
      "目標を達成しました！おめでとうございます。<br/>ご褒美はホルモンです、楽しんで下さい！",
      flash[:notice])
  end
  
  private
  def assert_show_user_without_log
    assert_equal "/user", path
    assert_equal "履歴が未登録です。", flash[:notice]
  end
  
  def login_action(mail_address, password)
    post_via_redirect "/login", :user => {
      :mail_address => mail_address,
      :password => password
    }
  end
  
  def edit_weight_log_action(weight_log, measure_date, weight)
    get "/user/weight_logs/" + weight_log.id.to_s + "/edit"
    assert_response :success
    
    put_via_redirect "/user/weight_logs/" + weight_log.id.to_s, :weight_log => {
      :measured_date => measure_date,
      :weight => weight
    }
  end
end
