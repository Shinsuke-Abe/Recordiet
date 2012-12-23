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

  describe "身長の追加" do
    before do
      @new_user_data = {
        :mail_address => "newuser@mail.com",
        :display_name => "new user name",
        :password => "password",
        :height => 160.5
      }
    end

    it "身長を追加可能" do
      new_user = User.new(@new_user_data)

      new_user.valid?.should be_true
    end

    it "身長を登録可能" do
      new_user = User.create(@new_user_data)

      new_user.height.should == 160.5
    end
  end

  describe ".bmi,ponderal_index" do
    it "体重履歴がない場合はnilが返る" do
      eric = FactoryGirl.create(:eric)
      eric.update_attributes(:height => 178.2)

      eric.bmi.should be_nil
      eric.ponderal_index.should be_nil
    end

    it "体重履歴があっても身長の設定がない場合はnilが返る" do
      eric = FactoryGirl.create(:eric_with_weight_logs)

      eric.bmi.should be_nil
      eric.ponderal_index.should be_nil
    end

    it "体重履歴があって身長の設定がある場合はbmiが計算される" do
      eric = FactoryGirl.create(:eric_with_weight_logs)
      eric.update_attributes(:height => 178.2)

      expected_bmi = (eric.latest_weight_log.weight / ((eric.height/100)**2)).round(2)
      eric.bmi.should == expected_bmi
    end

    # 正確な境界値が求めづらいので以下で範囲を取る(体重は75.4kg)
    # 2.1m やせ => 1
    # 1.8m 標準 => 2
    # 1.6m 肥満度1 => 3
    # 1.5m 肥満度2 => 4
    # 1.4m 肥満度3 => 5
    # 1.3m 肥満度4 => 6

    it "bmiが18.5未満の場合は肥満度が1となる" do
      assert_ponderal_index(210.0, 1, "やせ型")
    end

    it "bmiが18.5以上25未満の場合は肥満度が2となる" do
      assert_ponderal_index(180.0, 2, "標準")
    end

    it "bmiが25以上30未満の場合は肥満度が3となる" do
      assert_ponderal_index(160.0, 3, "肥満(肥満度1)")
    end

    it "bmiが30以上35未満の場合は肥満度が4となる" do
      assert_ponderal_index(150.0, 4, "肥満(肥満度2)")
    end

    it "bmiが35以上40未満の場合は肥満度が5となる" do
      assert_ponderal_index(140.0, 5, "肥満(肥満度3)")
    end

    it "bmiが40以上の場合は肥満度が6となる" do
      assert_ponderal_index(130.0, 6, "肥満(肥満度4)")
    end

    def assert_ponderal_index(height, expected_index, expected_display)
      eric = FactoryGirl.create(:eric_with_weight_logs)
      eric.update_attributes(:height => height)

      eric.ponderal_index.should == expected_index
      eric.display_ponderal_index == expected_display
    end
  end

  after do
    FactoryGirl.reload
  end
end
