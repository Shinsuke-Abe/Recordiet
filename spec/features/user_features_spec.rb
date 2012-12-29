# encoding: utf-8
require 'spec_helper'

describe "ユーザ機能" do
	before do
		@eric = FactoryGirl.create(:eric_with_weight_logs)
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

		it "身長も入力して成功する" do
		  new_user_action(
				:mail_address => "newuser@mail.com",
				:display_name => "new user name",
				:password => "userpass1234",
				:height => 180.9)

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

			it "身長も入力して成功する" do
			  new_eric_data = {
					:mail_address => "new_eric@derek.com",
					:display_name => "blind faith",
					:password => "layla",
					:height => 170.2
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

    not_login_access admin_confirm_path

    not_login_access admin_menu_path

    not_login_access admin_notifications_path
	end

	it "身長を入力するとBMI値エリアが表示される" do
		@eric.update_attributes(:height => 170.1)

		visit login_path
		current_path.should == login_path

		success_login_action @eric

		find("#bmi_area").should_not be_nil
	end

	describe "管理者権限の確認" do
		before do
			@admin = FactoryGirl.create(:admin)
		end

		it "管理者権限がある場合は管理者メニューを表示" do
			visit login_path
			success_login_action @admin

			page.should have_link "管理者メニュー"
		end

		it "管理者権限がない場合は管理者メニューを表示しない" do
		  visit login_path
		  success_login_action @eric

		  page.should_not have_link "管理者メニュー"
		end

		it "管理者メニューをクリックした場合は再度パスワードを要求する" do
		  visit login_path
		  success_login_action @admin

		  expect_to_click_link("管理者メニュー", admin_confirm_path)

		  find_field("confirm_password").value.should be_nil
		end

		it "管理者ログイン認証に失敗した場合は管理者ログインフォームが再表示される" do
			visit login_path
			success_login_action @admin

			expect_to_click_link("管理者メニュー", admin_confirm_path)

			find_field("confirm_password").value.should be_nil

			input_admin_confirm_password_and_post("invalid_password", false)
			# TODO エラー表示
		end

		it "管理者ログイン認証に成功した場合は管理者メニューが表示される" do
		  visit login_path
		  success_login_action @admin

		  expect_to_click_link("管理者メニュー", admin_confirm_path)

		  input_admin_confirm_password_and_post(@admin.password, true)
		end

		it "管理者ログイン認証成功後に管理者メニューをクリックすると管理者メニューが即時表示される" do
		  visit login_path
		  success_login_action @admin

		  expect_to_click_link("管理者メニュー", admin_confirm_path)

		  input_admin_confirm_password_and_post(@admin.password, true)

		  expect_to_click_link("体重履歴", weight_logs_path)

		  expect_to_click_link("管理者メニュー", admin_menu_path)
		end
	end

	after do
		FactoryGirl.reload
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
		fill_in "user_height", :with => input_user_data[:height]

		click_button button_name
	end

	def asser_user_edit_form(user_data)
		find_field("user_mail_address").value.should == user_data[:mail_address]
		find_field("user_display_name").value.should == user_data[:display_name]
		find_field("user_password").value.should be_nil
	end
end