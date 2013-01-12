require 'openssl'
class TwitterLink < ActiveRecord::Base
  attr_accessible :consumer_key, :consumer_secret

  validates :consumer_key, :consumer_secret, :presence => true

  def encrypt!
    self.consumer_key = encrypt_string(consumer_key)
    self.consumer_secret = encrypt_string(consumer_secret)
  end

  private
  def encrypt_string(target)
    enc = OpenSSL::Cipher::Cipher.new('aes256')
    enc.encrypt
    enc.pkcs5_keyivgen(ENV['SECRET_KEY'])

    ((enc.update(target) + enc.final).unpack("H*")).to_s
  end
end
