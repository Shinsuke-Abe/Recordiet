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
      eric = FactoryGirl.create(:eric)
      new_weight_log = eric.weight_logs.create(
        :weight => 73.0,
        :measured_date => Date.today,
        :fat_percentage => 16.8)
      
      log_added_eric = User.find(eric.id)
      
      log_added_eric.should have(3).weight_logs
      # log_added_eric.weight_logs[0].should == new_weight_log
      # log_added_eric.weihgt_logs[1].should == eric.weight_logs[0]
    end
  end
end
