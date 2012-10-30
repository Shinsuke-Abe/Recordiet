# encoding: utf-8
require 'test_helper'

class LoginControllerTest < ActionController::TestCase
  
  test "ログインフォームを表示する" do
    get :show
    assert_response :success
  end
  
  # test "the truth" do
  #   assert true
  # end
end
