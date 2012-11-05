# encoding: utf-8
require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  fixtures :users, :weight_logs
  
  test "show:履歴を持たないユーザを表示する" do
    assigned_john = show_user_action(:john)
    
    assert take_off_form_data(assigned_john.weight_logs).empty?
    assert_equal "履歴が未登録です。", flash[:notice]
  end
  
  test "show:履歴を持つユーザを表示する" do
    assigned_eric = show_user_action(:eric)
    
    assert_nil flash[:notice]
    assert_weight_logs users(:eric), assigned_eric
  end
  
  private
  def show_user_action(name)
    session[:id] = users(name).id
    
    get :show
    assert_response :success
    
    assigned_user = assigns(:user)
    
    assert_not_nil assigned_user
    assert_equal users(name), assigned_user
    
    assigned_user
  end

  # test "should create user" do
    # assert_difference('User.count') do
      # post :create, user: { display_name: @user.display_name, mail_address: @user.mail_address, password: @user.password }
    # end
# 
    # assert_redirected_to user_path(assigns(:user))
  # end
  
  # test "should destroy user" do
    # assert_difference('User.count', -1) do
      # delete :destroy, id: @user
    # end
# 
    # assert_redirected_to users_path
  # end
end
