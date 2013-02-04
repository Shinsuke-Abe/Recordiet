# encoding: utf-8
require 'spec_helper'

describe "目標管理機能" do
  before do
    @eric = FactoryGirl.create(:eric)
    @john = FactoryGirl.create(:john_with_milestone)
  end

  describe "目標の新規登録" do
    before do
      visit login_path
      success_login_action @eric

      expect_to_click_link("目標を設定する", new_milestone_path)
    end

    it "成功する" do
      create_milestone_action(
        :weight => 67.0,
        :fat_percentage => 24.0,
        :date => Date.today + 30.days,
        :reward => "焼き肉食べ放題")

      current_path.should == weight_logs_path

      expect(find("#milestone_area")).to have_link "目標変更"
    end

    it "エラーが発生する" do
      create_milestone_action(
        :fat_percentage => 24.0,
        :date => Date.today + 30.days,
        :reward => "テストご褒美\nバッグ")

      current_path.should == milestone_path

      has_form_error?
    end
  end

  describe "目標の変更" do
    before do
      visit login_path
      success_login_action @john
    end

    describe "修正" do
      before do
        expect_to_click_link("目標変更", edit_milestone_path)

        assert_edit_milestone_form(@john)
      end

      it "成功する" do
        edit_milestone_action(
          :weight => 65.0,
          :fat_percentage => 24.0,
          :date => Date.today + 60.days,
          :reward => "テストご褒美\nラーメン")

        current_path.should == weight_logs_path
      end

      it "目標の修正でエラーが発生した場合はフォームが再表示される" do
        edit_milestone_action(
          :weight => nil,
          :fat_percentage => 24.0,
          :date => Date.today + 60.days,
          :reward => "テストご褒美\nラーメン")

        current_path.should == milestone_path
        has_form_error?
      end
    end

    it "目標を削除する" do
      expect_to_click_link("目標削除", weight_logs_path)

      expect(find("div.alert.alert-info").find("p")).to have_content(
        application_message_for_test(:milestone_not_found))
      expect(find("#milestone_area")).to have_link "目標を設定する"
    end
  end

  it "履歴登録時に目標を達成した場合はメッセージが表示される" do
    visit login_path
    success_login_action @john

    create_weight_log_action(
      :weight => @john.milestone.weight - 0.1,
      :measured_date => Date.yesterday,
      :fat_percentage => @john.milestone.fat_percentage - 0.1)

    current_path.should == weight_logs_path

    expect(find("div.alert.alert-success")).to have_content(
      sprintf(
        application_message_for_test(:achieve_milestone),
        @john.milestone.reward))
    @john.achieved_milestone_logs.length.should == 1
  end

  it "目標の達成履歴を表示する" do
    visit login_path
    success_login_action @john

    expect_to_click_link("目標達成履歴", achieved_milestone_logs_path)
  end

  after do
    FactoryGirl.reload
  end

  def create_milestone_action(new_milestone_data)
    input_and_post_milestone_action(new_milestone_data, "登録する")
  end

  def edit_milestone_action(update_milestone_data)
    input_and_post_milestone_action(update_milestone_data, "更新する")
  end

  def input_and_post_milestone_action(input_and_post_milestone_action, button_name)
    fill_in "milestone_weight", :with => input_and_post_milestone_action[:weight]
    fill_in "milestone_fat_percentage", :with => input_and_post_milestone_action[:fat_percentage]
    if input_and_post_milestone_action[:date]
      select input_and_post_milestone_action[:date].year.to_s, :from => "milestone_date_1i"
      select input_and_post_milestone_action[:date].month.to_s + "月", :from => "milestone_date_2i"
      select input_and_post_milestone_action[:date].day.to_s, :from => "milestone_date_3i"
    end
    fill_in "milestone_reward", :with => input_and_post_milestone_action[:reward]

    click_button button_name
  end

  def assert_edit_milestone_form(user)
    find_field("milestone_weight").value.should == user.milestone.weight.to_s
    if user.milestone.fat_percentage
      find_field("milestone_fat_percentage").value.should == user.milestone.fat_percentage.to_s
    else
      find_field("milestone_fat_percentage").value.should be_nil
    end
    find_field("milestone_date_1i").value.should == user.milestone.date.year.to_s
    find_field("milestone_date_2i").value.should == user.milestone.date.month.to_s
    find_field("milestone_date_3i").value.should == user.milestone.date.day.to_s
    find_field("milestone_reward").value.should == user.milestone.reward.to_s
  end
end