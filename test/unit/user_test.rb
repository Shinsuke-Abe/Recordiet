# encoding: utf-8
require 'test_helper'

class UserTest < ActiveSupport::TestCase
  fixtures :users, :weight_logs, :menus, :milestones, :achieved_milestone_logs
  
  test "認証要求でメールアドレスとパスワードの両方が一致する場合はユーザ情報を返却する" do
    auth_user = User.authenticate(users(:john).mail_address, users(:john).password_digest)
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
  
  test "メールアドレスが一致するレコードがある場合はエラー" do
    new_user = User.new(
      :mail_address => users(:eric).mail_address,
      :display_name => "anonymous",
      :password => "newpass")
    assert new_user.invalid?
  end
  
  test "メールアドレスがemailの形式でない場合はエラー" do
    new_user = User.new(
      :mail_address => "mail",
      :display_name => "anonymous",
      :password => "newpass")
    assert new_user.invalid?
  end
  
  test "削除時は関連レコードも削除される" do
    # ActiveRecordは遅延ロードのため、
    # 事前に値を取得しておかないと削除された状態で検査してしまう
    before_destroy = User.find(users(:eric).id)
    before_destroy_weight_logs = before_destroy.weight_logs
    before_destroy_achieved_milestone_logs = before_destroy.achieved_milestone_logs
    before_destory_milestone = before_destroy.milestone
    
    eric = User.find(users(:eric).id)
    eric.destroy
     
    assert_raise(ActiveRecord::RecordNotFound) {
      User.find(before_destroy.id)
    }
    before_destroy_weight_logs.each do |weight_log|
      assert_raise(ActiveRecord::RecordNotFound) {
        WeightLog.find(weight_log.id)
      }
      weight_log.menus.each do |menu|
        assert_raise(ActiveRecord::RecordNotFound) {
          Menu.find(menu.id)
        }
      end
    end
     
    before_destroy_achieved_milestone_logs.each do |achieve|
      assert_raise(ActiveRecord::RecordNotFound) {
        AchievedMilestoneLog.find(achieve.id)
      }
    end
     
    assert_raise(ActiveRecord::RecordNotFound) {
      Milestone.find(before_destory_milestone.id)
    }
   end
end
