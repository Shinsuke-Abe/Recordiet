# encoding: utf-8
# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'capybara/rspec'
require 'factory_girl'

# To user factory_girl
FactoryGirl.find_definitions

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"
end

def success_login_action(login_user_data)
  if login_user_data.is_a? Hash
    input_and_post_login_data login_user_data

    current_path.should == weight_logs_path
    expect(find("#user_information_area")).to have_content login_user_data[:display_name]
  elsif login_user_data.is_a? User
    input_and_post_login_data(
      :mail_address => login_user_data.mail_address,
      :display_name => login_user_data.display_name,
      :password => login_user_data.password)

    current_path.should == weight_logs_path
    expect(find("#user_information_area")).to have_content login_user_data.display_name
  end
end

def input_and_post_login_data(auth_user_data)
  fill_in "user_mail_address", :with => auth_user_data[:mail_address]
  fill_in "user_password", :with => auth_user_data[:password]
  click_button "ログイン"
end

def create_weight_log_action(new_weight_log)
  input_and_post_weight_log_action(new_weight_log, "登録する")
end

def input_and_post_weight_log_action(input_weight_log_data, button_name)
  fill_in "weight_log_weight", :with => input_weight_log_data[:weight]
  select input_weight_log_data[:measured_date].year.to_s, :from => "weight_log_measured_date_1i"
  select input_weight_log_data[:measured_date].month.to_s + "月", :from => "weight_log_measured_date_2i"
  select input_weight_log_data[:measured_date].day.to_s, :from => "weight_log_measured_date_3i"
  fill_in "weight_log_fat_percentage", :with => input_weight_log_data[:fat_percentage]

  click_button button_name
end

def input_admin_confirm_password_and_post(password, valid_password)
  fill_in "confirm_password", :with => password
  click_button "確認"

  if valid_password
    current_path.should == admin_menu_path
  else
    current_path.should == admin_confirm_path
  end
end

def expect_to_click_link(button_name, expect_path)
  first(:link, button_name).click
  current_path.should == expect_path
end

def table_has_records?(record_count)
  expect(page).to have_selector "table tr"
  all("tr").length.should == (record_count + 1)
end

def expect_to_click_table_link(record_index, button_name, expect_path)
  table_record(record_index).first(:link, button_name).click
  current_path.should == expect_path
end

def table_record(record_index)
  find("tbody").all("tr")[record_index]
end

def has_form_error?
  expect(page).to have_css "span.help-inline"
end

def application_message_for_test(symbol)
  I18n.t(symbol, :scope => :application_messages)
end
