# encoding: utf-8
require 'test_helper'

class WeightLogsControllerTest < ActionController::TestCase
  fixtures :users, :weight_logs
  
  test "ログイン済のユーザに履歴を登録することができる" do
    session[:id] = users(:john).id
    post :create, :weight_log => {
      :measured_date => Date.today - 1,
      :weight => 70.9
    }
    
    john_log_added = assigns(:user)
    assert_equal 1, john_log_added.weight_logs.length
    assert_equal Date.today - 1, john_log_added.weight_logs[0].measured_date
    assert_equal 70.9, john_log_added.weight_logs[0].weight
  end
  
  test "計測日未指定の場合はエラーメッセージを表示する" do
    session[:id] = users(:eric).id
    post :create, :weight_log => {
      :weight => 55.5
    }
    
    eric_log_not_added = assigns(:user)
    p users(:eric).weight_logs
    p eric_log_not_added.weight_logs
    assert_equal users(:eric).weight_logs.length, eric_log_not_added.weight_logs.length
    assert_equal "記録の登録には計測日と体重が必要です。", flash[:notice]
  end
  # test "the truth" do
  #   assert true
  # end
end
