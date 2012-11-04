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
  # test "the truth" do
  #   assert true
  # end
end
