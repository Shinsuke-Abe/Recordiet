# encoding: utf-8
require 'test_helper'

class LoginsControllerTest < ActionController::TestCase
  test "ログインフォームを表示する" do
    get :show
    assert_response :success
  end
  #正しいユーザ名とパスワードを入力すると履歴画面に遷移する
  # test "the truth" do
  #   assert true
  # end
end
