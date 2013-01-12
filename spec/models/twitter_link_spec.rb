# encoding:utf-8
require 'spec_helper'
require 'openssl'

describe TwitterLink do
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

  describe ".encrypt!" do
    it "コンシューマーキーとシークレットを暗号化することができる" do
      ENV['SECRET_KEY'] = "secret"

      twitter_link = TwitterLink.new(
        :consumer_key => "con_key",
        :consumer_secret => "con_secret")

      expect_key = encrypt_string(twitter_link.consumer_key)
      expect_secret = encrypt_string(twitter_link.consumer_secret)

      twitter_link.encrypt!

      twitter_link.consumer_key.should == expect_key
      twitter_link.consumer_secret.should == expect_secret
    end

    def encrypt_string(target)
      enc = OpenSSL::Cipher::Cipher.new('aes256')
      enc.encrypt
      enc.pkcs5_keyivgen(ENV['SECRET_KEY'])

      ((enc.update(target) + enc.final).unpack("H*")).to_s
    end
  end
end
