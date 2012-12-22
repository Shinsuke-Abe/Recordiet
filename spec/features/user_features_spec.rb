# encoding: utf-8
require 'spec_helper'

describe "ユーザ機能" do
	before do
		@eric = FactoryGirl.create(:eric)
	end

	it "履歴未登録でログインすると履歴ページに未登録メッセージを表示する" do
		jimmy = FactoryGirl.create(:jimmy)
		visit login_path
		current_path.should == login_path

		success_login_action jimmy

		assert_weight_logs_page_without_logs_and_milestone
	end

	describe "ユーザ新規登録" do
		before do
			visit new_user_path
			current_path.should == new_user_path
		end

		it "成功する" do
			new_user_action(
				:mail_address => "newuser@mail.com",
				:display_name => "new user name",
				:password => "userpass1234")

			current_path.should == weight_logs_path

			assert_weight_logs_page_without_logs_and_milestone
		end

		it "登録済のメールアドレスでの新規登録は失敗する" do
			new_user_action(
				:mail_address => @eric.mail_address,
				:display_name => "duplicate user",
				:password => "dup9876")

			current_path.should == user_path
			has_form_error?
		end
	end

	describe "登録済のユーザ情報の操作" do
		before do
			visit login_path
			current_path.should == login_path

			success_login_action @eric
		end

		describe "変更" do
			before do
				expect_to_click_link("ユーザ情報変更", edit_user_path)

				asser_user_edit_form(
					:mail_address => @eric.mail_address,
					:display_name => @eric.display_name)
			end

			it "成功する" do
				new_eric_data = {
					:mail_address => "new_eric@derek.com",
					:display_name => "blind faith",
					:password => "layla"
				}

				edit_user_action new_eric_data

				current_path.should == weight_logs_path

				expect_to_click_link("ログアウト", login_path)

				success_login_action new_eric_data
			end

			it "ユーザ情報の変更に失敗する" do
				new_eric_data = {
					:mail_address => "new_eric@derek.com",
					:display_name => "blind faith",
					:password => nil
				}

				edit_user_action new_eric_data

				current_path.should == user_path
				has_form_error?
			end
		end

		it "退会する" do
		  expect_to_click_link("退会する", login_path)

		  failed_login_action(
		  	:mail_address => @eric.mail_address,
		  	:password => @eric.password)
		end
	end

	it "ログアウトする" do
	  visit login_path
	  current_path.should == login_path

	  success_login_action @eric

	  expect_to_click_link("ログアウト", login_path)

	  not_login_access weight_logs_path
	end

	it "未ログインユーザにアクセス制御をかける" do
		not_login_access weight_logs_path
    not_login_access edit_weight_log_path(@eric.id)

    not_login_access new_milestone_path
    not_login_access edit_milestone_path

    not_login_access achieved_milestone_logs_path

    not_login_access edit_user_path
	end

	def not_login_access(url)
		visit url
	  current_path.should == login_path
	  expect(find("div.alert.alert-block")).to have_content application_message_for_test(:login_required)
	end

	def failed_login_action(login_user_data)
		input_and_post_login_data login_user_data

		current_path.should == login_path
	  expect(find(".alert.alert-error")).to have_content application_message_for_test(:login_incorrect)
	end

	def assert_weight_logs_page_without_logs_and_milestone
		expect(page).to have_css "div.alert.alert-info"
		expect(find("div.alert.alert-info").find("p")).to have_content(
			application_message_for_test(:weight_log_not_found) + "\n" +
			application_message_for_test(:milestone_not_found))
		expect(find("#milestone_area")).to have_link "目標を設定する"
	end

	def new_user_action(new_user_data)
		input_and_post_user_action(new_user_data, "登録する")
	end

	def edit_user_action(edit_user_data)
		input_and_post_user_action(edit_user_data, "更新する")
	end

	def input_and_post_user_action(input_user_data, button_name)
		fill_in "user_mail_address", :with => input_user_data[:mail_address]
		fill_in "user_display_name", :with => input_user_data[:display_name]
		fill_in "user_password", :with => input_user_data[:password]

		click_button button_name
	end

	def asser_user_edit_form(user_data)
		find_field("user_mail_address").value.should == user_data[:mail_address]
		find_field("user_display_name").value.should == user_data[:display_name]
		find_field("user_password").value.should be_nil

	end
end