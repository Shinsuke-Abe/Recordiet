#encoding: utf-8
require 'spec_helper'

describe Notification do
  describe ".invalid?" do
    it "内容が未登録の場合はエラーになる" do
      notification = Notification.new(
      	:start_date => Date.yesterday,
      	:end_date => nil,
      	:is_important => false,
      	:content => nil)

      expect(notification.invalid?).to be_true
    end

    it "開始日付が終了日付よりも後の場合はエラーになる" do
      notification = Notification.new(
        :start_date => Date.tomorrow,
        :end_date => Date.yesterday,
        :is_important => false,
        :content => "テストお知らせ")

      expect(notification.invalid?).to be_true
    end
  end

  describe ".display_content" do
    before do
      @notification = Notification.new(
        :start_date => Date.yesterday,
        :end_date => nil,
        :content => "テストお知らせ")
    end

    it "is_importantフラグがtrueの場合は【重要】を頭につける" do
      @notification.is_important = true
      @notification.display_content.should == "【重要】テストお知らせ"
    end

    it "is_importantフラグがfalseの場合はcontentをそのまま返す" do
      @notification.is_important = false
      @notification.display_content.should == "テストお知らせ"
    end
  end

  describe ".effective_notification" do
    it "開始日付と終了日付が未入力のお知らせは表示対象" do
      notification = Notification.create(
        :content => "テストお知らせ")

      should_be_effective_notification notification.content
    end

    it "開始日付が入力されていて当日であれば表示対象" do
      notification = Notification.create(
        :start_date => Date.today,
        :content => "テストお知らせ。本日から")

      should_be_effective_notification notification.content
    end

    it "開始日付が入力されていて前日以前であれば表示対象" do
      notification = Notification.create(
        :start_date => Date.yesterday,
        :content => "テストお知らせ。昨日から")

      should_be_effective_notification notification.content
    end

    it "開始日付が入力されていて当日以降であれば表示対象外" do
      notification = Notification.create(
        :start_date => Date.tomorrow,
        :content => "テストお知らせ。明日から")

      expect(Notification.effective_notification).to be_empty
    end

    it "終了日付が入力されていて当日であれば表示対象" do
      notification = Notification.create(
        :end_date => Date.today,
        :content => "テストお知らせ。今日まで")

      should_be_effective_notification notification.content
    end

    it "終了日付が入力されていて明日以降であれば表示対象" do
      notification = Notification.create(
        :end_date => Date.tomorrow,
        :content => "テストお知らせ。明日まで")

      should_be_effective_notification notification.content
    end

    it "終了日付が入力されていて昨日以前であれば表示対象外" do
      notification = Notification.create(
        :end_date => Date.yesterday,
        :content => "テストお知らせ。昨日まで")

      expect(Notification.effective_notification).to be_empty
    end

    it "開始日付と終了日付の期間に当日が含まれる場合は表示対象" do
      notification = FactoryGirl.create(:notification_from_yesterday_to_tomorrow)

      should_be_effective_notification notification.content
    end

    it "開始日付と終了日付の期間に当日が含まれない場合は表示対象外" do
      notification = FactoryGirl.create(:notification_from_3days_ago_to_yesterday)

      expect(Notification.effective_notification).to be_empty
    end

    def should_be_effective_notification(expected_content)
      actual_array = Notification.effective_notification

      actual_array.length.should == 1
      actual_array[0].content.should == expected_content
    end
  end
end
