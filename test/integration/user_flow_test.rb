# encoding: utf-8
require 'test_helper'

class UserFlowTest < ActionDispatch::IntegrationTest
  fixtures :all
  
  def setup
    @eric = users(:eric)
    @john = users(:john)
  end
  
  test "履歴未登録：ログインすると履歴ページに未登録メッセージを表示する" do
    #https!
    # show_form_action login_path
    visit login_path
    assert_equal login_path, current_path, "failures at show login form"
    
    # login_action(
      # :mail_address => @john.mail_address,
      # :password => self.class.user_password(:john))
    # assert_show_user_without_log_and_milestone assigns(:current_user)
    fill_in "user_mail_address", :with => @john.mail_address
    fill_in "user_password", :with => self.class.user_password(:john)
    click_button "ログイン"
    assert_equal weight_logs_path, current_path, "failures at assert path after login action"
    page.has_css? "div.alert.alert-info"
    find("div.alert.alert-info").find("p").has_content? "履歴が未登録です。\n目標が未登録です。目標を立ててダイエットをしてみませんか？"
    find("#user_information_area").has_content? @john.display_name
    find("#milestone_area").has_button? "目標を設定する"
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
    
    get_via_redirect weight_logs_path
    assert_equal login_path, path
  end
  
  test "未ログインユーザにアクセス制御をかける" do
    not_logined_access weight_logs_path
    not_logined_access edit_weight_log_path(@john.id)
    
    not_logined_access new_milestone_path
    not_logined_access edit_milestone_path
    
    not_logined_access achieved_milestone_logs_path
    
    not_logined_access edit_user_path
  end
  
  private
  def not_logined_access(uri)
    visit uri
    assert_equal login_path, current_path
    find("div.alert.alert-block").has_content? "Recordietの各機能を使うにはログインが必要です。"
  end
end