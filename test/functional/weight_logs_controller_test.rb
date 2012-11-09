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
    assert_weight_log expected_data, john_log_added.weight_logs[0]
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
    assert_weight_log expected_data, updated_log
  end
  
  test "ログの変更内容の体重が未入力の場合はエラーメッセージを表示する" do
    update_weight_log_action(:eric, Date.yesterday)
      
    assert_equal "記録の登録には計測日と体重が必要です。", flash[:notice]
  end
  
  test "ログを削除するとログの件数が減る" do
    session[:id] = users(:eric).id
    delete :destroy, :id => users(:eric).weight_logs[0].id
    
    weight_logs_of_eric = User.find(users(:eric).id).weight_logs
    assert_equal users(:eric).weight_logs.length - 1, weight_logs_of_eric.length
    assert_nil weight_logs_of_eric.index{|log| log.id == users(:eric).weight_logs[0].id}
  end
  
  test "履歴を持たないユーザを表示する" do
    assigned_john = show_weight_logs_logged_in_user_action(:john)
    
    assert take_off_form_data(assigned_john.weight_logs).empty?
    assert_equal "履歴が未登録です。", flash[:notice]
  end
  
  test "履歴を持つユーザを表示する" do
    assigned_eric = show_weight_logs_logged_in_user_action(:eric)
    
    assert_nil flash[:notice]
    assert_weight_logs users(:eric), assigned_eric
  end
  
  private 
  def show_weight_logs_logged_in_user_action(name)
    session[:id] = users(name).id
    
    get :index
    assert_response :success
    
    assigned_user = assigns(:user)
    
    assert_not_nil assigned_user
    assert_equal users(name), assigned_user
    
    assigned_user
  end
  
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
  
  def assert_weight_log(expected, actual)
    assert_equal expected[:measured_date], actual.measured_date
    assert_equal expected[:weight], actual.weight
  end
end
