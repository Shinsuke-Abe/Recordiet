# encoding: utf-8
require 'spec_helper'

describe "体重履歴機能" do

	before do
		@eric = FactoryGirl.create(:eric_with_weight_logs)

		visit login_path
		success_login_action @eric
	end

	it "履歴登録済でログインすると履歴ページに一覧を表示する" do
	  current_path.should == weight_logs_path

	  table_has_records? @eric.weight_logs.length
	end

	it "登録済の履歴が16件以上の場合は履歴がページングされる" do
		FactoryGirl.create_list(:weight_log, 15, user: @eric)
		visit weight_logs_path

		current_path.should == weight_logs_path

		table_has_records? 15
		find("nav.pagination").should_not be_nil
	end

	it "体重履歴を登録する" do
		expected_logs_length = @eric.weight_logs.length + 1

		current_path.should == weight_logs_path

		create_weight_log_action(
			:weight => 73.8,
			:measured_date => Date.yesterday,
			:fat_percentage => 21.0)

		table_has_records? expected_logs_length
	end

	it "体重履歴を変更する" do
		show_edit_weight_log_form_action(0, @eric.latest_weight_log)

		edit_weight_log_action(
			:weight => 69.0,
			:measured_date => @eric.weight_logs[0].measured_date,
			:fat_percentage => nil)

	  current_path.should == weight_logs_path

	  User.find(@eric.id).latest_weight_log.weight.should == 69.0
	end

	it "体重履歴の変更でエラーが発生すると変更フォームを再表示する" do
	  show_edit_weight_log_form_action(0, @eric.latest_weight_log)

		edit_weight_log_action(
			:weight_log => nil,
			:measured_date => @eric.latest_weight_log.measured_date,
			:fat_percentage => @eric.latest_weight_log.fat_percentage)

		current_path.should == weight_log_path(@eric.latest_weight_log)
		has_form_error?
	end

	it "体重履歴を削除する" do
		expect_to_click_table_link(
			0, "削除", weight_logs_path)

	  eric_log_deleted = User.find(@eric.id)

	  table_has_records? eric_log_deleted.weight_logs.length
	end

	describe "食事内容新規登録" do
		before do
			expect_to_click_table_link(
				0, "食事内容追加", new_weight_log_menu_path(@eric.latest_weight_log))
		end

		it "食事内容を記録する" do
			create_menu_action(
				:menu_type => "朝食",
				:detail => "ご飯\nみそ汁\n納豆")

			current_path.should == weight_logs_path

			expect(table_record(0)).to have_link "食事内容表示"

			expect_to_click_table_link(
				0, "食事内容表示", weight_log_menus_path(@eric.latest_weight_log))

			table_has_records? @eric.latest_weight_log.menus.length
		end

		it "エラーが発生した場合はフォームが再表示される" do
		  create_menu_action(
		  	:menu_type => "夕食",
		  	:detail => nil)

		  current_path.should == weight_log_menus_path(@eric.latest_weight_log)
		  has_form_error?
		end
	end

	describe "食事内容変更" do
		before do
			expect_to_click_table_link(
				0, "食事内容追加", new_weight_log_menu_path(@eric.latest_weight_log))

			create_menu_action(
				:menu_type => "朝食",
				:detail => "ご飯\nみそ汁\n納豆")

			expect_to_click_table_link(
		  	0, "食事内容表示", weight_log_menus_path(@eric.latest_weight_log))
		end

		it "指定した食事内容を変更できる" do
			show_edit_menu_form(0, @eric.latest_weight_log.menus[0])

		  edit_menu_action(
		  	:menu_type => "夕食",
		  	:detail => "愛妻弁当")

		  current_path.should == weight_log_menus_path(@eric.latest_weight_log)
		end

		it "エラーが発生した場合はフォームが再表示される" do
			show_edit_menu_form(0, @eric.latest_weight_log.menus[0])

		  edit_menu_action(
		  	:menu_type => "夕食",
		  	:detail => nil)

		  current_path.should == weight_log_menu_path(@eric.latest_weight_log, @eric.latest_weight_log.menus[0].id)
		  has_form_error?
		end

		it "削除する" do
		  table_record(0).first(:link, "削除").click

		  find("tbody").all("tr").should be_empty
		end
	end

	describe "お知らせ機能" do
		it "お知らせがない場合はメッセージを表示しない" do
			proc {
				find("#system_notification")
				}.should raise_error(Capybara::ElementNotFound)
		end

		it "お知らせがある場合はメッセージを表示する" do
			notifications = [
			  FactoryGirl.create(:notification_from_tomorrow_to_3days_after),
			  FactoryGirl.create(:notification_from_today_to_tomorrow),
			  FactoryGirl.create(:notification_from_yesterday_to_tomorrow),
			  FactoryGirl.create(:notification_from_3days_ago_to_yesterday)]

			visit weight_logs_path

			expected_message = notifications[1..2].map { |notification| notification.display_content }

			expect(find("#system_notification")).to have_content expected_message.join("\n")
		end
	end

	after do
		FactoryGirl.reload
	end

	def edit_weight_log_action(update_weight_log_data)
		input_and_post_weight_log_action(update_weight_log_data, "更新する")
	end

	def show_edit_weight_log_form_action(log_index, weight_log)
		table_record(log_index).all("a.btn.btn-mini")[0].click

		current_path.should == edit_weight_log_path(weight_log.id)
		find_field("weight_log_weight").value.should == weight_log.weight.to_s
		if weight_log.fat_percentage
		 	find_field("weight_log_fat_percentage").value.should == weight_log.fat_percentage.to_s
		else
	 		find_field("weight_log_fat_percentage").value.should be_nil
		end
		find_field("weight_log_measured_date_1i").value.should == weight_log.measured_date.year.to_s
		find_field("weight_log_measured_date_2i").value.should == weight_log.measured_date.month.to_s
		find_field("weight_log_measured_date_3i").value.should == weight_log.measured_date.day.to_s
	end

	def show_edit_menu_form(menu_index, menu)
		table_record(menu_index).first(:link, "変更").click

		find_field("menu_menu_type").value.should == menu.menu_type.to_s
	  find_field("menu_detail").value.should == menu.detail
	end

	def create_menu_action(new_menu_data)
		input_and_post_menu_action(new_menu_data, "登録する")
	end

	def edit_menu_action(update_menu_data)
		input_and_post_menu_action(update_menu_data, "更新する")
	end

	def input_and_post_menu_action(input_menu_data, button_name)
		select input_menu_data[:menu_type], :from => "menu_menu_type"
	  fill_in "menu_detail", :with => input_menu_data[:detail]

	  click_button button_name
	end
end