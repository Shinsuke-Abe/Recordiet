# encoding: utf-8
require 'test_helper'

class WeightLogsControllerTest < ActionController::TestCase
  fixtures :users, :weight_logs
  
  test "ログイン済のユーザに履歴を登録することができる" do
    expected_data = { :measured_date => Date.today - 1, :weight => 70.9}
    john_log_added = register_weight_log_action(
      :john,
      expected_data[:measured_date],
      expected_data[:weight])

    assert_equal 1, john_log_added.weight_logs.length
    assert_equal expected_data[:measured_date], john_log_added.weight_logs[0].measured_date
    assert_equal expected_data[:weight], john_log_added.weight_logs[0].weight
  end
  
  test "計測日未指定の場合はエラーメッセージを表示する" do
    eric_log_not_added = register_weight_log_action(:john, nil, 55.5)
    
    assert_equal(
      users(:eric).weight_logs.length,
      User.find(users(:eric).id).weight_logs.length)
    assert_equal "記録の登録には計測日と体重が必要です。", flash[:notice]
  end
  
  test "指定したログの内容を修正することができる" do
    expected_data = {:measured_date => Date.yesterday, :weight => 69.0}
    update_weight_log_action(
      :eric,
      expected_data[:measured_date],
      expected_data[:weight])
    
    weight_log_of_eric = User.find(users(:eric).id).weight_logs
    updated_log = weight_log_of_eric[
      weight_log_of_eric.index{|weight_log|
        weight_log.id == users(:eric).weight_logs[1].id}] 
    assert_equal expected_data[:measured_date], updated_log.measured_date
    assert_equal expected_data[:weight], updated_log.weight
  end
  
  test "ログの変更内容の体重が未入力の場合はエラーメッセージを表示する" do
    update_weight_log_action(:eric, Date.yesterday)
      
    assert_equal "記録の登録には計測日と体重が必要です。", flash[:notice]
  end
  
  private 
  def register_weight_log_action(name, measured_date = nil, weight = nil)
    session[:id] = users(name).id
    post :create, :weight_log => {
      :measured_date => measured_date,
      :weight => weight
    }
    
    assigns(:user)
  end
  
  def update_weight_log_action(name, measured_date = nil, weight = nil)
    session[:id] = users(name).id
    put :update, {
      :id => users(name).weight_logs[1].id,
      :weight_log =>{
        :measured_date => measured_date,
        :weight => weight
      }}
  end
end
