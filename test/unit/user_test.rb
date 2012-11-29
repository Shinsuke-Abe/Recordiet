# encoding: utf-8
require 'test_helper'

class UserTest < ActiveSupport::TestCase
  fixtures :users, :weight_logs, :menus, :milestones, :achieved_milestone_logs
  
  def setup
    @john = users(:john)
    @eric = users(:eric)
    @create_user = lambda {|arg| User.new(arg)}
  end
  
  test "認証要求でメールアドレスとパスワードの両方が一致する場合はユーザ情報を返却する" do
    auth_user = User.authenticate(
      @john.mail_address,
      self.class.user_password(:john))
    assert_not_nil auth_user
    assert_equal @john, auth_user
  end
  
  test "認証要求でパスワードが一致しない場合はnilを返す" do
    assert_nil User.authenticate(@john.mail_address, "pass9876")
  end
  
  test "認証要求でメールアドレスが一致しない場合はnilを返す" do
    assert_nil User.authenticate(
      "nemo@mail.com",
      self.class.user_password(:john))
  end
  
  test "履歴あり：ユーザの履歴の存在確認" do
    eric = User.find(@eric.id)
    
    assert_weight_logs @eric, eric
  end
  
  test "履歴なし：ユーザの履歴の存在確認" do
    john = User.find(@john.id)
    
    assert john.weight_logs.empty?
  end
  
  test "メールアドレスが未入力の場合はエラー" do
    assert_validates_invalid(
      @create_user,
      {
        :mail_address => nil,
        :display_name => "new user name",
        :password => "userpass" 
      })
  end
  
  test "表示名が未入力の場合はエラー" do
    assert_validates_invalid(
      @create_user,
      {
        :mail_address => "newuser@mail.com",
        :display_name => nil,
        :password => "userpass"
      })
  end
  
  test "パスワードが未入力の場合はエラー" do
    assert_validates_invalid(
      @create_user,
      {
        :mail_address => "newuser@mail.com",
        :display_name => "new user name",
        :password => nil
      })
  end
  
  test "メールアドレスが一致するレコードがある場合はエラー" do
    assert_validates_invalid(
      @create_user,
      {
        :mail_address => @eric.mail_address,
        :display_name => "anonymous",
        :password => "newpass"
      })
  end
  
  test "メールアドレスがemailの形式でない場合はエラー" do
    assert_validates_invalid(
      @create_user,
      {
        :mail_address => "mail",
        :display_name => "anonymous",
        :password => "newpass"
      })
  end
  
  test "ユーザの登録に成功する" do
    new_user = User.new(
      :mail_address => "newuser@mail.com",
      :display_name => "new user name",
      :password => "hoge")
    assert new_user.valid?
    assert new_user.save
    
    new_user_password = BCrypt::Password.new(new_user.password_digest)
    assert new_user_password == "hoge"
  end
  
  test "削除時は関連レコードも削除される" do
    # ActiveRecordは遅延ロードのため、
    # 事前に値を取得しておかないと削除された状態で検査してしまう
    before_destroy = User.find(@eric.id)
    before_destroy_weight_logs = before_destroy.weight_logs
    before_destroy_achieved_milestone_logs = before_destroy.achieved_milestone_logs
    before_destory_milestone = before_destroy.milestone
    
    eric = User.find(@eric.id)
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
