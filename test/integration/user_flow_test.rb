# encoding: utf-8
require 'test_helper'

class UserFlowTest < ActionDispatch::IntegrationTest
  fixtures :all
  
  def setup
    @eric = users(:eric)
    @john = users(:john)
  end
  
  test "履歴未登録：ログインすると履歴ページに未登録メッセージを表示する" do
    https!
    show_form_action login_path
    
    login_action(
      :mail_address => @john.mail_address,
      :password => self.class.user_password(:john))
    assert_show_user_without_log_and_milestone assigns(:current_user)
  end
  
  test "ユーザ登録が成功する" do
    https!
    show_form_action new_user_path
    assert assigns(:user)
    
    post_via_redirect user_path, :user => {
      :mail_address => "jimmy@ledzeppelin.com",
      :display_name => "jimmy page",
      :password => "guitar"}
    
    assert_show_user_without_log_and_milestone assigns(:current_user)
  end
  
  test "登録済みのメールアドレスでの登録は失敗する" do
    https!
    show_form_action new_user_path
    assert assigns(:user)
    
    post_via_redirect user_path, :user => {
      :mail_address => @eric.mail_address,
      :display_name => "jimmy page",
      :password => "guitar"}
    assert_equal user_path, path
  end
  
  test "ユーザ情報を変更する" do
    https!
    login_action(
      :mail_address => @eric.mail_address,
      :password => self.class.user_password(:eric))
    
    show_form_action edit_user_path
    
    put_via_redirect user_path, :user => {
      :mail_address => "new_eric@derek.com",
      :display_name => "blind faith",
      :password => "layla"
    }
    assert_show_user_log
    
    delete_via_redirect login_path
    assert_equal login_path, path
    
    login_action(
      :mail_address => "new_eric@derek.com",
      :password => "layla")
    assert_show_user_log
  end
  
  test "退会する" do
    https!
    login_action(
      :mail_address => @eric.mail_address,
      :password => self.class.user_password(:eric))
    
    delete_via_redirect user_path
    
    assert_equal login_path, path
    
    post_via_redirect login_path, :user => {
      :mail_address => @eric.mail_address,
      :password => @eric.password
    }
    assert_equal login_path, path
  end
  
  test "ログアウトする" do
    https!
    login_action(
      :mail_address => @eric.mail_address,
      :password => self.class.user_password(:eric))
    
    delete_via_redirect login_path
    assert_equal login_path, path
    
    required_login_filtered weight_logs_path
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
    
    # user_controllerはedit,update,destroyが対象
    required_login_filtered edit_user_path
  end
  
  private
  def required_login_filtered(uri)
    get uri
    assert login_path, path
  end
end