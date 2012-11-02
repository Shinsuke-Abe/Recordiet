# encoding: utf-8
require 'test_helper'

class LoginsControllerTest < ActionController::TestCase
  fixtures :users
  
  test "ログインフォームを表示する" do
    get :show
    assert_response :success
  end
  
  test "正しいユーザ名とパスワードを入力すると履歴画面に遷移する" do
    post :create, :user => {:mail_address => users(:one).mail_address, :password => users(:one).password}
    
    assert_redirected_to user_path
    assert_equal session[:id], users(:one).id
  end
  
  test "間違ったユーザ名とパスワードを入力するとログインフォームを再表示する" do
    post :create, :user => {:mail_address => "nemo@mail.com", :password => "noname1234"}
    
    assert_response :success
    assert_equal "メールアドレスかパスワードが間違っています。", flash[:notice]
  end
  #
  
  # 
  # test "the truth" do
  #   assert true
  # end
end
