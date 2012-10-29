require 'test_helper'

class WeightLogFlowTest < ActionDispatch::IntegrationTest
  fixtures :all
  
  test "ユーザログイン済：履歴未登録の状態では一覧ではなくメッセージを表示する" do
    https!
    # セッションに保持しなければならない値はペンディング
    # テストを詰めていく中で決める
    get "/users", nil, {"user_id" => 1}
    
    assert_response :success
    assert_equal "履歴が未登録です。", flash[:notice]
  end
  # ユーザログイン済：履歴の登録済の一覧が表示
  
  # test "the truth" do
  #   assert true
  # end
end
