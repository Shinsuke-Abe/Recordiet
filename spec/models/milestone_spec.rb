# encoding: utf-8
require 'spec_helper'

describe Milestone do
  describe ".invalid?" do
    it "目標体重が未入力の場合はtrueになる" do
      new_milestone = Milestone.new(
        :weight => nil,
        :fat_percentage => 20.0,
        :date => Date.tomorrow,
        :reward => "旅行")
      expect(new_milestone.invalid?).to be_true
    end
    
    it "過去日付を指定した場合はtrueになる" do
      new_milestone = Milestone.new(
        :weight => 70.0,
        :fat_percentage => 20.0,
        :date => Date.yesterday - 4.days,
        :reward => "デート")
      expect(new_milestone.invalid?).to be_true
    end
  end
  
  describe ".valid?" do
    it "体脂肪率は未入力でもtrueになる" do
      new_milestone = Milestone.new(
        :weight => 65.0,
        :fat_percentage => nil,
        :date => Date.tomorrow,
        :reward => "小遣い")
      expect(new_milestone.valid?).to be_true
    end
    
    it "期限は未入力でもtrueになる" do
      new_milestone = Milestone.new(
        :weight => 60.0,
        :fat_percentage => 20.0,
        :date => nil,
        :reward => "おいしいもの")
      expect(new_milestone.valid?).to be_true
    end
    
    it "ご褒美は未入力でもtrueになる" do
      new_milestone = Milestone.new(
        :weight => 70.0,
        :fat_percentage => 20.0,
        :date => Date.tomorrow,
        :reward => nil)
      expect(new_milestone.valid?).to be_true
    end
  end
end
