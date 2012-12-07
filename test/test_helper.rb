# encoding: utf-8

ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'test/unit/ui/console/testrunner'
require 'capybara/rails'
class Test::Unit::UI::Console::TestRunner
  def guess_color_availability 
    true 
  end
end

DatabaseCleaner.strategy = :truncation

class ActionDispatch::IntegrationTest
  include Capybara::DSL
  
  self.use_transactional_fixtures = false

  teardown do
    DatabaseCleaner.clean
    Capybara.reset_sessions!
    Capybara.use_default_driver
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
  
  def show_form_action(uri)
    get uri
    assert_response :success
  end
  
  # helper method for capybara
  def create_weight_log_action(new_weight_log)
    input_and_post_weight_log_data new_weight_log, "登録する"
  end
  
  def input_and_post_weight_log_data(weight_log, button_name)
    fill_in "weight_log_weight", :with => weight_log[:weight]
    select weight_log[:measured_date].year.to_s, :from => "weight_log_measured_date_1i"
    select weight_log[:measured_date].month.to_s + "月", :from => "weight_log_measured_date_2i"
    select weight_log[:measured_date].day.to_s, :from => "weight_log_measured_date_3i"
    fill_in "weight_log_fat_percentage", :with => weight_log[:fat_percentage]
    
    click_button button_name
  end
  
  def success_login_action(auth_user_data)
    input_and_post_login_data auth_user_data
    
    assert_equal weight_logs_path, current_path,
      sprintf("failures at login user action. user_name=%s, password=%s",
              auth_user_data[:mail_address],
              auth_user_data[:password])          
    find("#user_information_area").has_content? auth_user_data[:display_name]
  end
  
  def input_and_post_login_data(auth_user_data)
    fill_in "user_mail_address", :with => auth_user_data[:mail_address]
    fill_in "user_password", :with => auth_user_data[:password]
    click_button "ログイン"
  end
  
  def user_login_data(user_symbol)
    user = users(user_symbol)
    {
      :mail_address => user.mail_address,
      :password => self.class.user_password(user_symbol),
      :display_name => user.display_name
    }
  end
  
  def has_form_error?
    assert page.has_css? "span.help-inline"
  end
  
  def table_has_records?(record_number)
    assert page.has_selector? "table tr"
    assert_equal record_number + 1, all("tr").length
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
  
  def assert_show_user_log
    assert_equal weight_logs_path, path
    assert assigns(:current_user)
  end
  
  def assert_show_user_without_log_and_milestone(user)
    assert take_off_form_data(user.weight_logs).empty?
    assert_nil user.milestone
  end
  
  # テストからだとI18nのショートカットメソッドにアクセスできないので、
  # テスト用にヘルパメソッドを作成
  def application_message_for_test(message_symbol)
    I18n.t(message_symbol, :scope => :application_messages)
  end
  
  def self.user_password(user_symbol)
    case user_symbol
    when :one
      "MyString"
    when :two
      "MyString2"
    when :john
      "pass1234"
    when :eric
      "ocean461"
    end
  end
  
  def assert_validates_invalid(arg)
    new_model = yield arg
    assert new_model.invalid?
  end
end
