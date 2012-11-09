require 'test_helper'

class AchievedMilestoneLogsControllerTest < ActionController::TestCase
  fixtures :users
  test "should get index" do
    session[:id] = users(:john)
    get :index
    assert_response :success
  end

end
