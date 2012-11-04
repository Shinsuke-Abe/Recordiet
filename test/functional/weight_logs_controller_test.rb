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
    assert_equal(
      users(:eric).weight_logs.length,
      User.find(users(:eric).id).weight_logs.length)
    assert_equal "記録の登録には計測日と体重が必要です。", flash[:notice]
  end
  
  test "指定したログの内容を修正することができる" do
    session[:id] = users(:eric).id
    put :update, {
      :id => users(:eric).weight_logs[1].id,
      :weight_log =>{
        :measured_date => Date.yesterday,
        :weight => 69.0
      }}
    
    weight_log_of_eric = User.find(users(:eric).id).weight_logs
    updated_log = weight_log_of_eric[
      weight_log_of_eric.index{|weight_log|
        weight_log.id == users(:eric).weight_logs[1].id}] 
    assert_equal Date.yesterday, updated_log.measured_date
    assert_equal 69.0, updated_log.weight
  end
  
  test "ログの変更内容の体重が未入力の場合はエラーメッセージを表示する" do
    session[:id] = users(:eric).id
    put :update, {
      :id => users(:eric).weight_logs[1].id,
      :weight_log =>{
        :measured_date => Date.yesterday,
        :weight => nil
      }}
      
    assert_equal "記録の登録には計測日と体重が必要です。", flash[:notice]
  end
end
