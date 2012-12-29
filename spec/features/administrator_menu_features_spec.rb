# encoding: utf-8
require 'spec_helper'

describe "管理者メニュー機能" do
	# TODO お知らせ管理メニューでは今の有効な一覧を表示する
	# TODO お知らせの新規追加可能
	# TODO お知らせの変更可能
	# TODO お知らせの削除
	# 以下はweight_logs_features_spec
	# TODO 表示される
	it "管理者メニューにはお知らせ管理リンクが表示されている" do
	  admin = FactoryGirl.create(:admin)

	  visit login_path
	  success_login_action admin

	  expect_to_click_link("管理者メニュー", admin_confirm_path)

	  input_admin_confirm_password_and_post(admin.password, true)

	  current_path.should == admin_menu_path

	  page.should have_link "お知らせ管理"
	end
end