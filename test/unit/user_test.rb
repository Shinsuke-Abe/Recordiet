# encoding: utf-8
require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "認証要求でメールアドレスとパスワードの両方が一致する場合はユーザ情報を返却する" do
    auth_user = User.authenticate("john@mail.com", "pass1234")
    assert_not_nil auth_user
    assert_equal auth_user.mail_address, "john@mail.com"
    assert_equal auth_user.display_name, "john denver"
    assert_equal auth_user.password, "pass1234"
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
