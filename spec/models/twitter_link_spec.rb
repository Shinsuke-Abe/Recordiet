# encoding:utf-8
require 'spec_helper'

describe TwitterLink do
  describe ".invalid" do
    it "コンシューマーキーが未入力" do
      twitter_link = TwitterLink.new(
        :consumer_secret => "secret")

      expect(twitter_link.invalid?).to be_true
    end
  end
end
