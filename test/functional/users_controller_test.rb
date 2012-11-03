# encoding: utf-8
require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  
  test "show:履歴を持たないユーザを表示する" do
    session[:id] = users(:john).id
    
    get :show
    assert_response :success
    
    assigned_john = assigns(:user)
    assert_not_nil assigned_john
    assert_equal assigned_john, users(:john)
    assert assigned_john.weight_logs.empty?
    assert_equal "履歴が未登録です。", flash[:notice]
  end
  
  test "show:履歴を持つユーザを表示する" do
    session[:id] = users(:eric).id
    
    get :show
    assert_response :success
    
    assigned_eric = assigns(:user)
    assert_not_nil assigned_eric
    assert_nil flash[:notice]
    assert_equal assigned_eric.weight_logs.length, 2
    for weight_log in users(:eric).weight_logs do
      assert assigned_eric.weight_logs.include?(weight_log)
    end
  end
  
  # setup do
    # @user = users(:one)
  # end
# 
  # test "should get index" do
    # get :index
    # assert_response :success
    # assert_not_nil assigns(:users)
  # end
# 
  # test "should get new" do
    # get :new
    # assert_response :success
  # end
# 
  # test "should create user" do
    # assert_difference('User.count') do
      # post :create, user: { display_name: @user.display_name, mail_address: @user.mail_address, password: @user.password }
    # end
# 
    # assert_redirected_to user_path(assigns(:user))
  # end
# 
  # test "should show user" do
    # get :show, id: @user
    # assert_response :success
  # end
# 
  # test "should get edit" do
    # get :edit, id: @user
    # assert_response :success
  # end
# 
  # test "should update user" do
    # put :update, id: @user, user: { display_name: @user.display_name, mail_address: @user.mail_address, password: @user.password }
    # assert_redirected_to user_path(assigns(:user))
  # end
# 
  # test "should destroy user" do
    # assert_difference('User.count', -1) do
      # delete :destroy, id: @user
    # end
# 
    # assert_redirected_to users_path
  # end
end
