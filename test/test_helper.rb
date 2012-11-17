ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'test/unit/ui/console/testrunner'
class Test::Unit::UI::Console::TestRunner
  def guess_color_availability 
    true 
  end
end

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all, :users

  # Add more helper methods to be used by all tests here...
  
  def assert_weight_logs(expect_user, actual_user)
    actual_weight_logs = take_off_form_data(actual_user.weight_logs)
    assert_equal expect_user.weight_logs.length, actual_weight_logs.length
    
    for weight_log in expect_user.weight_logs do
      assert actual_weight_logs.include?(weight_log)
    end
  end
  
  def take_off_form_data(weight_logs)
    weight_logs.select { |log|
      log.id != nil
    }
  end
  
  def login_action(args)
    mail_address = args[:mail_address]
    password = args[:password]
    
    post_via_redirect login_path, :user => {
      :mail_address => mail_address,
      :password => password
    }
    assert_show_user_log
  end
  
  def assert_show_user_log
    assert_equal weight_logs_path, path
    assert assigns(:user)
  end
  
  def show_form_action(uri)
    get uri
    assert_response :success
  end
  
  def assert_show_user_without_log_and_milestone
    assert_equal(
      WeightLogsHelper::WEIGHT_LOG_NOT_FOUND + "\n" +
      WeightLogsHelper::MILESTONE_NOT_FOUND,
      flash[:notice])
  end
  
  def create_weight_log_action(args)
    measure_date = args[:measured_date]
    weight = args[:weight]
    
    post_via_redirect weight_logs_path, :weight_log => {
      :measured_date => measure_date,
      :weight => weight
    }
    assert_show_user_log
  end
end
