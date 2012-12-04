# encoding: utf-8
require 'test_helper'

class UserTest < ActiveSupport::TestCase
  fixtures :users, :weight_logs, :menus, :milestones, :achieved_milestone_logs
  
  def setup
    @john = users(:john)
    @eric = users(:eric)
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
      :mail_address => nil,
      :display_name => "new user name",
      :password => "userpass") do |arg|
      User.new(arg)
    end
  end
  
  test "表示名が未入力の場合はエラー" do
    assert_validates_invalid(
      :mail_address => "newuser@mail.com",
      :display_name => nil,
      :password => "userpass") do |arg|
      User.new(arg)
    end
  end
  
  test "パスワードが未入力の場合はエラー" do
    assert_validates_invalid(
      :mail_address => "newuser@mail.com",
      :display_name => "new user name",
      :password => nil) do |arg|
      User.new(arg)
    end
  end
  
  test "メールアドレスが一致するレコードがある場合はエラー" do
    assert_validates_invalid(
      :mail_address => @eric.mail_address,
      :display_name => "anonymous",
      :password => "newpass") do |arg|
      User.new(arg)
    end
  end
  
  test "メールアドレスがemailの形式でない場合はエラー" do
    assert_validates_invalid(
      :mail_address => "mail",
      :display_name => "anonymous",
      :password => "newpass") do |arg|
      User.new(arg)
    end
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
   
   test "最新の日付の体重履歴を取得できる" do
     eric = users(:eric)
     expect_weight_log = weight_logs(:two)
     
     assert_equal expect_weight_log, eric.latest_weight_log
   end
   
   test "目標が設定されている場合は目標までの体重を取得できる" do
     eric = users(:eric)
     expect_weight = (eric.latest_weight_log.weight - eric.milestone.weight).round(2)
     
     assert_equal expect_weight, eric.weight_to_milestone
   end
   
   test "目標が設定されていない場合、目標までの体重はnilが返る" do
     john = users(:john)
     john.weight_logs.build(
       :measured_date => Date.today,
       :weight => 65.0).save
     
     assert_nil john.weight_to_milestone
   end
   
   test "体重履歴が存在しない場合、目標までの体重はnilが返る" do
     john = users(:john)
     john.create_milestone(
       :weight => 50.0,
       :date => Date.today + 60.days).save
     
     assert_nil john.weight_to_milestone
   end
   
   test "目標が設定されている場合は目標までの日数を取得できる" do
     eric = users(:eric)
     expect_days = (eric.milestone.date - Date.today).to_i
     
     assert_equal expect_days, eric.days_to_milestone
   end
   
   test "目標が設定されていない場合、目標までの日数はnilが返る" do
     john = users(:john)
     
     assert_nil john.days_to_milestone
   end
   
   test "目標が設定されている場合は目標までの体脂肪率を取得できる" do
     john = users(:john)
     john.weight_logs.build(
       :measured_date => Date.today,
       :weight => 65.0,
       :fat_percentage => 23.0).save
     john.create_milestone(
       :weight => 50.0,
       :fat_percentage => 22.0,
       :date => Date.today + 60.days).save
     
     expect_fat_percentage = (john.latest_weight_log_has_fat_percentage.fat_percentage - john.milestone.fat_percentage).round(2)
     assert_equal expect_fat_percentage, john.fat_percentage_to_milestone
   end
   
   test "目標が設定されていない場合、目標までの体脂肪率はnilが返る" do
     eric = users(:eric)
     eric.weight_logs.build(
       :measured_date => Date.today,
       :weight => 65.0,
       :fat_percentage => 23.0).save
     
     assert_nil eric.fat_percentage_to_milestone
   end
   
   test "体脂肪率を記録した体重履歴が存在しない場合、目標までの体脂肪率はnilが返る" do
     eric = users(:eric)
     eric.create_milestone(
       :weight => 50.0,
       :fat_percentage => 22.0,
       :date => Date.today + 60.days).save
     
     assert_nil eric.fat_percentage_to_milestone
   end
   
   test "データベースにフィックスしている体重履歴のリストを取得することができる" do
     eric = users(:eric)
     eric.weight_logs.build(
       :measured_date => Date.today,
       :weight => 65.0,
       :fat_percentage => 23.0)
     
     assert_equal 2, eric.fixed_weight_logs.length
     assert_equal weight_logs(:two), eric.fixed_weight_logs[0]
     assert_equal weight_logs(:one), eric.fixed_weight_logs[1]
   end
end
