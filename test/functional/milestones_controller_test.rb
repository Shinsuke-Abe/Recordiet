# encoding: utf-8
require 'test_helper'

class MilestonesControllerTest < ActionController::TestCase

  test "目標入力フォームを開く" do
    get :new
    
    assigns(:milestone)
  end
  # test "the truth" do
  #   assert true
  # end
end
