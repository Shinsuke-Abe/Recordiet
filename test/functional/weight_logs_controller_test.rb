# encoding: utf-8
require 'test_helper'


class WeightLogsControllerTest < ActionController::TestCase
  fixtures :users, :weight_logs
  
  def setup
    @eric = users(:eric)
    @john = users(:john)
  end
  
  test "ログイン済のユーザに履歴を登録することができる" do
    expected_data = { :measured_date => Date.today - 1, :weight => 70.9}
    john_log_added = register_weight_log_action(@john, expected_data)

    assert_equal 1, john_log_added.weight_logs.length
    assert_weight_log expected_data, john_log_added.weight_logs[0]
  end
  
  test "計測日未指定の場合は履歴が追加されない" do
    eric_log_not_added = register_weight_log_action(@john, {
      :measured_date => nil,
      :weight => 55.5})
    
    assert_equal(
      @eric.weight_logs.length,
      User.find(@eric.id).weight_logs.length)
  end
  
  test "指定したログの内容を修正することができる" do
    expected_data = {:measured_date => Date.yesterday, :weight => 69.0}
    update_weight_log_action(@eric, 1, expected_data)
    
    weight_log_of_eric = User.find(@eric.id).weight_logs
    updated_log = weight_log_of_eric[
      get_index_same_id(
        weight_log_of_eric, @eric.weight_logs[1])]
    assert_weight_log expected_data, updated_log
  end
  
  test "ログの変更内容の体重が未入力の場合はエラーメッセージを表示する" do
    update_weight_log_action(@eric, 1, {:measured_date => Date.yesterday, :weight => nil})
    assert assigns(:weight_log).errors
  end
  
  test "ログを削除するとログの件数が減る" do
    session[:id] = @eric.id
    delete :destroy, :id => @eric.weight_logs[0].id
    
    weight_logs_of_eric = User.find(@eric.id).weight_logs
    assert_equal @eric.weight_logs.length - 1, weight_logs_of_eric.length
    assert_nil get_index_same_id(weight_logs_of_eric, @eric.weight_logs[0])
  end
  
  test "履歴を持たないユーザを表示する" do
    assigned_john = show_weight_logs_logged_in_user_action(@john)
    
    assert take_off_form_data(assigned_john.weight_logs).empty?
    assert_equal(
      application_message_for_test(:weight_log_not_found) + "\n" +
      application_message_for_test(:milestone_not_found),
      flash[:notice])
  end
  
  test "履歴を持つユーザを表示する" do
    assigned_eric = show_weight_logs_logged_in_user_action(@eric)
    
    assert_nil flash[:notice]
    assert_weight_logs @eric, assigned_eric
  end
  
  private 
  def show_weight_logs_logged_in_user_action(show_user)
    session[:id] = show_user.id
    
    get :index
    assert_response :success
    
    assigned_user = assigns(:user)
    
    assert_not_nil assigned_user
    assert_equal show_user, assigned_user
    
    assigned_user
  end
  
  def register_weight_log_action(log_added_user, new_log)
    session[:id] = log_added_user.id
    post :create, :weight_log => new_log
    
    assigns(:user)
  end
  
  def update_weight_log_action(log_updated_user, update_log_index, updated_log)
    session[:id] = log_updated_user.id
    put :update, {
      :id => log_updated_user.weight_logs[update_log_index].id,
      :weight_log =>updated_log}
  end
  
  def assert_weight_log(expected, actual)
    assert_equal expected[:measured_date], actual.measured_date
    assert_equal expected[:weight], actual.weight
  end
  
  def get_index_same_id(weight_logs_in_db, selected_weight_log)
    weight_logs_in_db.index{|weight_log| weight_log.id == selected_weight_log.id}
  end
end
