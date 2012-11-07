# encoding: utf-8
require 'test_helper'

class MilestonesControllerTest < ActionController::TestCase
  fixtures :users, :milestones
  
  test "目標入力フォームを開く" do
    session[:id] = users(:john)
    get :new
    assigns(:user)
    assigns(:milestone)
  end
end
