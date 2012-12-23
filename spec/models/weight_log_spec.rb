# encoding: utf-8
require 'spec_helper'

describe WeightLog do
  describe ".invalid?" do
    before do
      @new_weight_log_data = {
        :weight => 68.5,
        :measured_date => Date.today,
        :fat_percentage => 23.0
      }
    end

    it "日付が未入力の場合はtrueが返る" do
      @new_weight_log_data[:measured_date] = nil
      new_weight_log = WeightLog.new(@new_weight_log_data)

      expect(new_weight_log.invalid?).to be_true
    end

    it "体重が未入力の場合はtrueが返る" do
      @new_weight_log_data[:weight] = nil
      new_weight_log = WeightLog.new(@new_weight_log_data)

      expect(new_weight_log.invalid?).to be_true
    end

    it "体重が0で入力された場合はtrueが返る" do
      @new_weight_log_data[:weight] = 0
      new_weight_log = WeightLog.new(@new_weight_log_data)

      expect(new_weight_log.invalid?).to be_true
    end

    it "体重が負数で入力された場合はtrueが返る" do
      @new_weight_log_data[:weight] = -1
      new_weight_log = WeightLog.new(@new_weight_log_data)

      expect(new_weight_log.invalid?).to be_true
    end
  end

  describe "default order" do
    it "計測日の降順にソートされる" do
      eric = FactoryGirl.create(:eric_with_weight_logs)

      expected_date_1 = eric.weight_logs[0].measured_date
      expected_date_2 = eric.weight_logs[1].measured_date

      eric.weight_logs.create(
        :weight => 73.0,
        :measured_date => Date.today,
        :fat_percentage => 16.8)

      log_added_eric = User.find(eric.id)

      log_added_eric.should have(3).weight_logs
      log_added_eric.latest_weight_log.measured_date.should eql Date.today
      log_added_eric.weight_logs[1].measured_date.should eql expected_date_1
      log_added_eric.weight_logs[2].measured_date.should eql expected_date_2
    end
  end

  describe ".create(after create)" do
    before do
      @john = FactoryGirl.create(:john_with_milestone)
      @new_weight_log_data = {
        :measured_date => Date.yesterday,
        :weight => 66.0,
        :fat_percentage => 21.0
      }
    end

    it "体重目標も体脂肪率目標も達成していない場合は達成履歴が作成されない" do
      @john.weight_logs.create(@new_weight_log_data)

      @john.achieved_milestone_logs.should be_empty
    end

    it "体重目標を達成した場合は目標体重が記録された達成履歴が作成される" do
      @new_weight_log_data[:weight] = 64.9
      @john.weight_logs.create(@new_weight_log_data)

      @john.should have(1).achieved_milestone_logs

      achieved_log = @john.achieved_milestone_logs.first
      achieved_log.achieved_date.should eql Date.yesterday
      achieved_log.milestone_weight.should eql @john.milestone.weight
      achieved_log.milestone_fat_percentage.should be_nil
    end

    it "体脂肪率目標を達成した場合は目標体脂肪率が記録された達成履歴が作成される" do
      @new_weight_log_data[:fat_percentage] = 19.5
      @john.weight_logs.create(@new_weight_log_data)

      @john.should have(1).achieved_milestone_logs

      achieved_log = @john.achieved_milestone_logs.first
      achieved_log.achieved_date.should eql Date.yesterday
      achieved_log.milestone_weight.should be_nil
      achieved_log.milestone_fat_percentage.should eql @john.milestone.fat_percentage
    end

    it "体重目標と体脂肪率目標を達成した場合は両者が記録された達成履歴が作成される" do
      @new_weight_log_data[:weight] = 64.9
      @new_weight_log_data[:fat_percentage] = 19.5

      @john.weight_logs.create(@new_weight_log_data)

      achieved_log = @john.achieved_milestone_logs.first

      achieved_log.achieved_date.should eql Date.yesterday
      achieved_log.milestone_weight.should eql @john.milestone.weight
      achieved_log.milestone_fat_percentage.should eql @john.milestone.fat_percentage
    end
  end

  describe ".achieved?" do
    before do
      @john = FactoryGirl.create(:john_with_milestone)
      @new_weight_log_data = {
        :measured_date => Date.yesterday,
        :weight => 66.0,
        :fat_percentage => 21.0
      }
    end

    it "体重が目標値より上の場合はfalseが返る" do
      @john.weight_logs.create(@new_weight_log_data)

      expect(@john.latest_weight_log.achieved?).to be_false
    end

    it "体重が目標値と同じ場合はtrueが返る" do
      @new_weight_log_data[:weight] = 65.5
      @john.weight_logs.create(@new_weight_log_data)

      expect(@john.latest_weight_log.achieved?).to be_true
    end

    it "体重が目標値未満の場合はtrueが返る" do
      @new_weight_log_data[:weight] = 65.4
      @john.weight_logs.create(@new_weight_log_data)

      expect(@john.latest_weight_log.achieved?).to be_true
    end

    it "体脂肪率が目標値よりも上の場合はfalseが返る" do
      @john.weight_logs.create(@new_weight_log_data)

      expect(@john.latest_weight_log.achieved?).to be_false
    end

    it "体脂肪率が目標値と同じ場合はtrueが返る" do
      @new_weight_log_data[:fat_percentage] = 20.0
      @john.weight_logs.create(@new_weight_log_data)

      expect(@john.latest_weight_log.achieved?).to be_true
    end

    it "体脂肪率が目標値未満の場合はtrueが返る" do
      @new_weight_log_data[:fat_percentage] = 19.9
      @john.weight_logs.create(@new_weight_log_data)

      expect(@john.latest_weight_log.achieved?).to be_true
    end
  end

  describe ".create" do
    it "計測日はユーザごとにユニークになる" do
      eric = FactoryGirl.create(:eric_with_weight_logs)

      new_weight_log = eric.weight_logs.create(
        :measured_date => eric.latest_weight_log.measured_date,
        :weight => 65.0)
      new_weight_log.should have_at_least(1).errors
    end
  end

  describe "ページング設定" do
    before do
      @eric = FactoryGirl.create(:eric_with_weight_logs, weight_logs_count: 17)
    end

    it "1ページあたり15ページとする" do
      @eric.weight_logs.page(1).length.should == 15
      @eric.weight_logs.page(2).length.should == 2

      @eric.weight_logs.page(1)[0].id.should == @eric.latest_weight_log.id
    end

    it "ページ番号未指定の場合は最初のページを表示する" do
      @eric.weight_logs.page(nil).length.should == 15

      @eric.weight_logs.page(nil)[0].id.should == @eric.latest_weight_log.id
    end
  end

  after do
    FactoryGirl.reload
  end
end
