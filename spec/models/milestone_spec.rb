# encoding: utf-8
require 'spec_helper'

describe Milestone do
  before do
    @new_milestone_data = {
      :weight => 70.0,
      :fat_percentage => 20.0,
      :date => Date.tomorrow,
      :reward => "テストご褒美"
    }
  end
    
  describe ".invalid?" do
    it "目標体重が未入力の場合はtrueになる" do
      @new_milestone_data[:weight] = nil
      new_milestone = Milestone.new(@new_milestone_data)
      
      expect(new_milestone.invalid?).to be_true
    end
    
    it "過去日付を指定した場合はtrueになる" do
      @new_milestone_data[:date] = Date.yesterday - 4.days
      new_milestone = Milestone.new(@new_milestone_data)
      
      expect(new_milestone.invalid?).to be_true
    end
  end
  
  describe ".valid?" do
    it "体脂肪率は未入力でもtrueになる" do
      @new_milestone_data[:fat_percentage] = nil
      new_milestone = Milestone.new(@new_milestone_data)
      
      expect(new_milestone.valid?).to be_true
    end
    
    it "期限は未入力でもtrueになる" do
      @new_milestone_data[:date] = nil
      new_milestone = Milestone.new(@new_milestone_data)
      
      expect(new_milestone.valid?).to be_true
    end
    
    it "ご褒美は未入力でもtrueになる" do
      @new_milestone_data[:reward] = nil
      new_milestone = Milestone.new(@new_milestone_data)
      
      expect(new_milestone.valid?).to be_true
    end
  end
end
