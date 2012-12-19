# encoding: utf-8
require 'spec_helper'

describe "ログインページ" do
	it "履歴未登録でログインすると履歴ページに未登録メッセージを表示する" do
		jimmy = FactoryGirl.create(:jimmy)
		visit login_path
		current_path.should == login_path

		fill_in "user_mail_address", :with => jimmy.mail_address
		fill_in "user_password", :with => jimmy.password
		click_button "ログイン"

		current_path.should == weight_logs_path
		expect(find("#user_information_area")).to have_content(jimmy.display_name)

		assert_weight_logs_page_without_logs_and_milestone
	end

	it "ユーザ登録が成功する" do
		visit new_user_path
		current_path.should == new_user_path

		new_user_action(
			:mail_address => "newuser@mail.com",
			:display_name => "new user name",
			:password => "userpass1234")

		current_path.should == weight_logs_path

		assert_weight_logs_page_without_logs_and_milestone
	end

	it "登録済のメールアドレスでの新規登録は失敗する" do
		eric = FactoryGirl.create(:eric)
		visit new_user_path
		current_path.should == new_user_path

		new_user_action(
			:mail_address => eric.mail_address,
			:display_name => "duplicate user",
			:password => "dup9876")

		current_path.should == user_path
		expect(page).to have_css "span.help-inline"
	end

	it "ユーザ情報を変更する" do
		eric = FactoryGirl.create(:eric)
		visit login_path
		current_path.should == login_path

		fill_in "user_mail_address", :with => eric.mail_address
		fill_in "user_password", :with => eric.password
		click_button "ログイン"

		current_path.should == weight_logs_path

		first(:link, "ユーザ情報変更").click

		current_path.should == edit_user_path
	end

	def assert_weight_logs_page_without_logs_and_milestone
		expect(page).to have_css "div.alert.alert-info"
		expect(find("div.alert.alert-info").find("p")).to have_content(
			application_message_for_test(:weight_log_not_found) + "\n" +
			application_message_for_test(:milestone_not_found))
		expect(find("#milestone_area")).to have_link "目標を設定する"
	end

	def new_user_action(new_user_data)
		fill_in "user_mail_address", :with => new_user_data[:mail_address]
		fill_in "user_display_name", :with => new_user_data[:display_name]
		fill_in "user_password", :with => new_user_data[:password]

		click_button "登録する"
	end
end