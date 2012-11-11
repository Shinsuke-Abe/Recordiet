# encoding: utf-8
require 'test_helper'

class UserTest < ActiveSupport::TestCase
  fixtures :users
  
  test "認証要求でメールアドレスとパスワードの両方が一致する場合はユーザ情報を返却する" do
    auth_user = User.authenticate(users(:john).mail_address, users(:john).password)
    assert_not_nil auth_user
    assert_equal users(:john), auth_user
  end
  
  test "認証要求でパスワードが一致しない場合はnilを返す" do
    assert_nil User.authenticate(users(:john), "pass9876")
  end
  
  test "認証要求でメールアドレスが一致しない場合はnilを返す" do
    assert_nil User.authenticate("nemo@mail.com", users(:john))
  end
  
  test "履歴あり：ユーザの履歴の存在確認" do
    eric = User.find(users(:eric).id)
    
    assert_weight_logs users(:eric), eric
  end
  
  test "履歴なし：ユーザの履歴の存在確認" do
    john = User.find(users(:john))
    
    assert john.weight_logs.empty?
  end
  
  test "メールアドレスが未入力の場合はエラー" do
    new_user = User.new(
      :mail_address => nil,
      :display_name => "new user name",
      :password => "userpass")
    assert new_user.invalid?
  end
  
  test "表示名が未入力の場合はエラー" do
    new_user = User.new(
      :mail_address => "newuser@mail.com",
      :display_name => nil,
      :password => "userpass")
    assert new_user.invalid?
  end
  
  test "パスワードが未入力の場合はエラー" do
    new_user = User.new(
      :mail_address => "newuser@mail.com",
      :display_name => "new user name",
      :password => nil)
    assert new_user.invalid?
  end
end
