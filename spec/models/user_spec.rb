# encoding: utf-8
require 'spec_helper'

describe User do
  describe ".authenticate" do
    before do
      @john = FactoryGirl.create(:john)
    end
    
    it "メールアドレスとパスワードの両方が一致する場合はユーザ情報を返す" do
      auth_user = User.authenticate(
        @john.mail_address,
        @john.password)
      
      auth_user.should == @john
    end
    
    it "パスワードが一致しない場合はnilを返す" do
      auth_user = User.authenticate(
        @john.mail_address,
        "invalid_password")
      
      auth_user.should be_nil
    end
    
    it "メールアドレスが一致しない場合はnilを返す" do
      auth_user = User.authenticate(
        "not_found@mail.com",
        @john.password)
      
      auth_user.should be_nil
    end
  end
  
  describe ".invalid?" do
    before do
      @new_user_data = {
        :mail_address => "newuser@mail.com",
        :display_name => "new user name",
        :password => "password"
      }
    end
    
    it "メールアドレスが未入力の場合はtrueが返る" do
      @new_user_data[:mail_address] = nil
      new_user = User.new(@new_user_data)
      
      expect(new_user.invalid?).to be_true
    end
    
    it "表示名が未入力の場合はtrueが返る" do
      @new_user_data[:display_name] = nil
      new_user = User.new(@new_user_data)
      
      expect(new_user.invalid?).to be_true
    end
    
    it "パスワードが未入力の場合はtrueが返る" do
      @new_user_data[:password] = nil
      new_user = User.new(@new_user_data)
      
      expect(new_user.invalid?).to be_true
    end
    
    it "既に一致するメールアドレスがある場合はtrueが返る" do
      john = FactoryGirl.create(:john)
      
      @new_user_data[:mail_address] = john.mail_address
      new_user = User.new(@new_user_data)
      
      expect(new_user.invalid?).to be_true
    end
    
    it "メールアドレスがemail形式でない場合はtrueが返る" do
      @new_user_data[:mail_address] = "mail"
      new_user = User.new(@new_user_data)
      
      expect(new_user.invalid?).to be_true
    end
  end
end
