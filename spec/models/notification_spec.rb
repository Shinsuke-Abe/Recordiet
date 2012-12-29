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
  end
end
