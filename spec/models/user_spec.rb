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

  describe ".latest_weight_log" do
    it "最新の体重履歴を取得できる" do
      eric = FactoryGirl.create(:eric_with_weight_logs)

      expected_weight_log = eric.weight_logs[0]

      expect(eric.latest_weight_log).to eql expected_weight_log
    end
  end

  describe ".weight_to_milestone" do
    it "目標が設定されている場合は目標までの体重を取得できる" do
      eric = FactoryGirl.create(:eric_with_weight_logs)
      eric.create_milestone(
        :weight => 64.0,
        :fat_percentage => 15.0,
        :date => Date.tomorrow)

      expected_weight = (eric.latest_weight_log.weight - eric.milestone.weight).round(2)

      expect(eric.weight_to_milestone).to eql expected_weight
    end

    it "目標が設定されていない場合はnilを返す" do
      eric = FactoryGirl.create(:eric_with_weight_logs)

      expect(eric.weight_to_milestone).to be_nil
    end

    it "履歴が存在しない場合はnilを返す" do
      john = FactoryGirl.create(:john_with_milestone)

      expect(john.weight_to_milestone).to be_nil
    end
  end

  describe ".days_to_milestone" do
    it "目標が設定されている場合は目標までの日数を取得できる" do
      john = FactoryGirl.create(:john_with_milestone)

      expected_days = (john.milestone.date - Date.today).to_i

      expect(john.days_to_milestone).to eql expected_days
    end

    it "目標が設定されていない場合はnilが返る" do
      john = FactoryGirl.create(:john)

      expect(john.days_to_milestone).to be_nil
    end
  end

  describe ".fat_precentage_to_milestone" do
    it "目標が設定されている場合は目標までの体脂肪率を取得できる" do
      eric = FactoryGirl.create(:eric_with_weight_logs)
      eric.create_milestone(
        :weight => 64.0,
        :fat_percentage => 15.0,
        :date => Date.tomorrow)

      expected_percentage = (eric.latest_weight_log.fat_percentage - eric.milestone.fat_percentage).round(2)

      expect(eric.fat_percentage_to_milestone).to eql expected_percentage
    end

    it "目標が設定されていない場合はnilが返る" do
      eric = FactoryGirl.create(:eric_with_weight_logs)

      expect(eric.fat_percentage_to_milestone).to be_nil
    end

    it "体脂肪率を記録した履歴が存在しない場合はnilが返る" do
      john = FactoryGirl.create(:john_with_milestone)

      expect(john.fat_percentage_to_milestone).to be_nil
    end
  end

  after do
    FactoryGirl.reload
  end
end
