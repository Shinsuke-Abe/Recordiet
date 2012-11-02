# encoding: utf-8
require 'test_helper'

class UserTest < ActiveSupport::TestCase
  fixtures :users
  
  test "認証要求でメールアドレスとパスワードの両方が一致する場合はユーザ情報を返却する" do
    auth_user = User.authenticate(users(:john).mail_address, users(:john).password)
    assert_not_nil auth_user
    assert_equal auth_user.mail_address, users(:john).mail_address
    assert_equal auth_user.display_name, users(:john).display_name
    assert_equal auth_user.password, users(:john).password
  end
  
  test "認証要求でパスワードが一致しない場合はnilを返す" do
    assert_nil User.authenticate("john@mail.com", "pass9876")
  end
  
  test "認証要求でメールアドレスが一致しない場合はnilを返す" do
    assert_nil User.authenticate("nemo@mail.com", "pass1234")
  end
  
  # test "the truth" do
  #   assert true
  # end
end
