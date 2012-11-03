# encoding: utf-8
require 'test_helper'

class WeightLogFlowTest < ActionDispatch::IntegrationTest
  fixtures :all
  
  test "履歴未登録：ログインすると履歴ページに未登録メッセージを表示する" do
    https!
    get "/login"
    assert_response :success
    
    post_via_redirect "/login", :user => {
      :mail_address => "john@mail.com",
      :password => "pass1234"}
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
    post_via_redirect "/login", :user => {
      :mail_address => "eric@mail.com",
      :password => "pass9876"}
    assert_equal "/user", path
    assert assigns(:user)
    assert assigns(:user => :weight_logs)
  end
  
  # test "the truth" do
  #   assert true
  # end
  
  private
  def assert_show_user_without_log
    assert_equal "/user", path
    assert_equal "履歴が未登録です。", flash[:notice]
  end
end
