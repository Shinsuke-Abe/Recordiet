require 'openssl'
class TwitterLink < ActiveRecord::Base
  attr_accessible :consumer_key, :consumer_secret

  validates :consumer_key, :consumer_secret, :presence => true

  before_save :encrypt!

  def encrypt!
    self.consumer_key = encrypt_string(consumer_key)
    self.consumer_secret = encrypt_string(consumer_secret)
  end

  def decrypt!
    self.consumer_key = decrypt_string(consumer_key)
    self.consumer_secret = decrypt_string(consumer_secret)
  end

  private
  def encrypt_string(target)
    crypted = crypt_string(target) do |cipher|
      cipher.encrypt
    end

    Base64.encode64(crypted).encode('utf-8')
  end

  def decrypt_string(target)
    crypt_string(Base64.decode64(target.encode('ascii-8bit'))) do |cipher|
      cipher.decrypt
    end
  end

  def create_crypt
    cipher = OpenSSL::Cipher::Cipher.new('aes256')
    yield cipher
    cipher.pkcs5_keyivgen(ENV['SECRET_KEY'])

    cipher
  end

  def crypt_string(target)
    crypt_object = create_crypt do |cipher|
      yield cipher
    end

    result_string = ""
    result_string << crypt_object.update(target)
    result_string << crypt_object.final

    result_string
  end
end
