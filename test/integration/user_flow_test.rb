# encoding: utf-8
require 'test_helper'

class UserFlowTest < ActionDispatch::IntegrationTest
  fixtures :all
  
  def setup
    @eric = users(:eric)
    @john = users(:john)
  end
  
  test "履歴未登録：ログインすると履歴ページに未登録メッセージを表示する" do
    visit login_path
    assert_equal login_path, current_path, "failures at show login form"
    
    success_login_action(
      :mail_address => @john.mail_address,
      :password => self.class.user_password(:john),
      :display_name => @john.display_name)
    
    assert_weight_logs_page_without_logs_and_milestone
  end
  
  test "ユーザ登録が成功する" do
    visit new_user_path
    assert_equal new_user_path, current_path, "failures at show create user form"
    
    create_user_action(
      :mail_address => "jimmy@ledzeppelin.com",
      :display_name => "jimmy page",
      :password => "guitar")
    
    assert_equal weight_logs_path, current_path, "failures at create user"
    
    assert_weight_logs_page_without_logs_and_milestone
  end
  
  test "登録済みのメールアドレスでの登録は失敗する" do
    visit new_user_path
    assert_equal new_user_path, current_path, "failures at show create user form"
    
    create_user_action(
      :mail_address => @eric.mail_address,
      :display_name => "jimmy page",
      :password => "guitar")
    
    assert_equal user_path, current_path, "not failures at create user"
    page.has_css? "help_inline"
  end
  
  test "ユーザ情報を変更する" do
    visit login_path
    assert_equal login_path, current_path, "failures at show login form"
    
    success_login_action(
      :mail_address => @eric.mail_address,
      :password => self.class.user_password(:eric),
      :display_name => @eric.display_name)
    
    first(:link, "ユーザ情報変更").click
    
    assert_equal edit_user_path, current_path, "failures at click user edit link"
    
    assert_equal @eric.mail_address, find_field("user_mail_address").value
    assert_equal @eric.display_name, find_field("user_display_name").value
    assert_nil find_field("user_password").value
    
    new_eric_data = {
      :mail_address => "new_eric@derek.com",
      :display_name => "blind faith",
      :password => "layla"
    }
    update_user_action(new_eric_data)
    
    assert_equal weight_logs_path, current_path, "failures at update user"
    
    first(:link, "ログアウト").click
    
    assert_equal login_path, current_path, "failures at logout"
    
    success_login_action(new_eric_data)
  end
  
  test "退会する" do
    visit login_path
    assert_equal login_path, current_path, "failures at show login form"
    
    eric_auth_data = {
      :mail_address => @eric.mail_address,
      :password => self.class.user_password(:eric),
      :display_name => @eric.display_name
    }
    
    success_login_action(eric_auth_data)
    
    first(:link, "退会する").click
    
    assert_equal login_path, current_path, "failures at delete user"
    
    failed_login_action(eric_auth_data)
  end
  
  test "ログアウトする" do
    visit login_path
    assert_equal login_path, current_path, "failures at show login form"
    
    success_login_action(
      :mail_address => @eric.mail_address,
      :password => self.class.user_password(:eric),
      :display_name => @eric.display_name)
    
    first(:link, "ログアウト").click
    
    assert_equal login_path, current_path, "failures at logout"
    
    not_logined_access weight_logs_path
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
  def success_login_action(auth_user_data)
    input_and_post_login_data auth_user_data
    
    assert_equal weight_logs_path, current_path,
      sprintf("failures at login user action. user_name=%s, password=%s",
              auth_user_data[:mail_address],
              auth_user_data[:password])          
    find("#user_information_area").has_content? auth_user_data[:display_name]
  end
  
  def failed_login_action(auth_user_data)
    input_and_post_login_data auth_user_data
    
    assert_equal login_path, current_path,
      sprintf("failures at login on not found user action. user_name=%s, password=%s",
              auth_user_data[:mail_address],
              auth_user_data[:password])
    find(".alert.alert-error").has_content? application_message_for_test(:login_incorrect)
  end
  
  def input_and_post_login_data(auth_user_data)
    fill_in "user_mail_address", :with => auth_user_data[:mail_address]
    fill_in "user_password", :with => auth_user_data[:password]
    click_button "ログイン"
  end
  
  def not_logined_access(uri)
    visit uri
    
    assert_equal login_path, current_path, sprintf("not-logined access failures when visit %s", uri)
    find("div.alert.alert-block").has_content? application_message_for_test(:login_required)
  end
  
  def create_user_action(input_user_data)
    input_and_post_user_action(input_user_data, "登録する")
  end
  
  def update_user_action(input_user_data)
    input_and_post_user_action(input_user_data, "更新する")
  end
  
  def input_and_post_user_action(input_user_data, button_name)
    fill_in "user_mail_address", :with => input_user_data[:mail_address]
    fill_in "user_display_name", :with => input_user_data[:display_name]
    fill_in "user_password", :with => input_user_data[:password]
    
    click_button button_name
  end
  
  def assert_weight_logs_page_without_logs_and_milestone
    page.has_css? "div.alert.alert-info"
    
    find("div.alert.alert-info").find("p").has_content?(
      application_message_for_test(:weight_log_not_found) + "\n" + 
      application_message_for_test(:milestone_not_found))
    find("#milestone_area").has_button? "目標を設定する"
  end
end