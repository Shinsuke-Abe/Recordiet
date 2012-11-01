# encoding: utf-8
require 'test_helper'

class WeightLogFlowTest < ActionDispatch::IntegrationTest
  fixtures :all
  
  test "履歴未登録：ログインすると履歴ページに未登録メッセージを表示する" do
    https!
    get "/login"
    assert_response :success
    
    post_via_redirect "/login", :user => {:mail_address => "john@mail.com", :password => "pass1234"}
    assert_equal "/user", path
    assert_equal "履歴が未登録です。", flash[:notice]
  end
  
  # 履歴登録済：ログインすると履歴ページに一覧を表示する
  
  # test "the truth" do
  #   assert true
  # end
end
