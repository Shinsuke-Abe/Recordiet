# encoding: utf-8
require 'spec_helper'

describe "管理者メニュー機能" do
	before do
		@admin = FactoryGirl.create(:admin)

		visit login_path
		success_login_action @admin

		expect_to_click_link("管理者メニュー", admin_confirm_path)

		input_admin_confirm_password_and_post(@admin.password, true)

		current_path.should == admin_menu_path
	end

	it "管理者メニューのリンクが表示されている" do
	  page.should have_link "お知らせ管理"
	  page.should have_link "アプリケーション設定確認"
	end

	describe "アプリケーション設定確認" do
		it "設定ビューアが開く" do
			expect_to_click_link("アプリケーション設定確認", admin_app_setting_path)
		end
	end

	describe "お知らせ管理メニュー" do
		before do
			expect_to_click_link("お知らせ管理", admin_notifications_path)
		end

		it "お知らせ未登録の場合は0件のテーブルが表示される" do
		  table_has_records? 0
		end

		describe "お知らせ登録フォーム" do
			before do
				expect_to_click_link("新規作成", new_admin_notification_path)
			end

			it "登録が正常に終了する" do
			  create_notification_action(
			  	:start_date => Date.today - 30.days,
			  	:end_date => Date.today + 10.days,
			  	:is_important => true,
			  	:content => "テストお知らせ\n新機能追加")

			  current_path.should == admin_notifications_path
			  table_has_records? 1
			end

			it "登録でエラーが発生する" do
			  create_notification_action(
			  	:start_date => Date.today - 30.days,
			  	:end_date => Date.today + 10.days,
			  	:is_important => true,
			  	:content => nil)

			  current_path.should == admin_notifications_path
			  has_form_error?
			end
		end

		describe "お知らせ変更フォーム" do
			before do
				@notifications = FactoryGirl.create_list(:notification, 5)

				visit admin_notifications_path
			end

			it "変更が正常に終了する" do
			  expect_to_click_table_link(1, "変更", edit_admin_notification_path(@notifications[1].id))

			  edit_notification_action(
			  	:start_date => Date.today - 30.days,
			  	:end_date => Date.today + 10.days,
			  	:is_important => false,
			  	:content => "テストお知らせ\n機能変更")

			  current_path.should == admin_notifications_path
			end

			it "変更でエラーが発生する" do
			  expect_to_click_table_link(2, "変更", edit_admin_notification_path(@notifications[2].id))

			  edit_notification_action(
			  	:start_date => Date.today + 25.days,
			  	:end_date => Date.today + 15.days,
			  	:is_important => false,
			  	:content => nil)

			  current_path.should == admin_notification_path(@notifications[2].id)
			  has_form_error?
			end
		end

		it "指定したお知らせを削除できる" do
		  notifications = FactoryGirl.create_list(:notification, 5)
		  expected_length = notifications.length - 1

		  visit admin_notifications_path

		  table_has_records? notifications.length

		  expect_to_click_table_link(3, "削除", admin_notifications_path)

		  table_has_records? expected_length
		end

		def create_notification_action(new_notification)
			input_and_post_notification_action(new_notification, "登録する")
		end

		def edit_notification_action(update_notificaiton)
			input_and_post_notification_action(update_notificaiton, "更新する")
		end

		def input_and_post_notification_action(input_notification_data, button_name)
			select input_notification_data[:start_date].year.to_s, :from => "notification_start_date_1i"
		  select input_notification_data[:start_date].month.to_s + "月", :from => "notification_start_date_2i"
		  select input_notification_data[:start_date].day.to_s, :from => "notification_start_date_3i"

		  select input_notification_data[:end_date].year.to_s, :from => "notification_end_date_1i"
		  select input_notification_data[:end_date].month.to_s + "月", :from => "notification_end_date_2i"
		  select input_notification_data[:end_date].day.to_s, :from => "notification_end_date_3i"

		  if input_notification_data[:is_important]
		  	check("notification_is_important")
			end

		  fill_in "notification_content", :with => input_notification_data[:content]

		  click_button button_name
		end
	end

	after do
	  FactoryGirl.reload
	end
end