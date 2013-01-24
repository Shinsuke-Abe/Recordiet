# encoding:utf-8
require 'spec_helper'
require 'openssl'

describe TwitterLink do
  # TODO テーブルでの管理はやめて環境変数にする
  describe ".invalid" do
    it "コンシューマーキーが未入力" do
      twitter_link = TwitterLink.new(
        :consumer_secret => "secret")

      expect(twitter_link.invalid?).to be_true
    end

    it "コンシューマーシークレットが未入力" do
      twitter_link = TwitterLink.new(
        :consumer_key => "key")

      expect(twitter_link.invalid?).to be_true
    end
  end

  describe "暗号化" do
    before do
      ENV['SECRET_KEY'] = "secret"

      @twitter_link = TwitterLink.new(
        :consumer_key => "con_key",
        :consumer_secret => "con_secret")
    end

    it "コンシューマーキーとシークレットを暗号化することができる" do
      expect_key = encrypt_string(@twitter_link.consumer_key)
      expect_secret = encrypt_string(@twitter_link.consumer_secret)

      @twitter_link.encrypt!

      assert_twitter_link expect_key, expect_secret, @twitter_link
    end

    it "暗号化されたコンシューマーキーとシークレットを複合化することができる" do
      expect_key = @twitter_link.consumer_key
      expect_secret = @twitter_link.consumer_secret

      @twitter_link.encrypt!
      @twitter_link.decrypt!

      assert_twitter_link expect_key, expect_secret, @twitter_link
    end

    it "永続化時に暗号化される" do
      expect_key = encrypt_string(@twitter_link.consumer_key)
      expect_secret = encrypt_string(@twitter_link.consumer_secret)

      @twitter_link.save

      actual_twitter_link = TwitterLink.find(:first)

      assert_twitter_link expect_key, expect_secret, actual_twitter_link
    end

    def assert_twitter_link(expect_key, expect_secret, actual)
      actual.consumer_key.should == expect_key
      actual.consumer_secret.should == expect_secret
    end

    def encrypt_string(target)
      enc = OpenSSL::Cipher::Cipher.new('aes256')
      enc.encrypt
      enc.pkcs5_keyivgen(ENV['SECRET_KEY'])

      encrypted = ""
      encrypted << enc.update(target)
      encrypted << enc.final

      Base64.encode64(encrypted).encode('utf-8')
    end
  end
end
