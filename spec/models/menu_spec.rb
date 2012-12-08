# encoding: utf-8
require 'spec_helper'

describe Menu do
  describe ".invalid?" do
    it "食事種類が未入力の場合はtrueになる" do
      new_menu = Menu.new(
        :menu_type => nil,
        :detail => "シリアル")
      # new_menu.invalid?.should be_true
      expect(new_menu.invalid?).to be_true
    end
    
    it "食事内容が未入力の場合はtrueになる" do
      new_menu = Menu.new(
        :menu_type => 1,
        :detail => nil)
      expect(new_menu.invalid?).to be_true
    end
    
    it "食事種類が0の場合はtrueになる" do
      new_menu = Menu.new(
        :menu_type => 0,
        :detail => "シリアル")
      expect(new_menu.invalid?).to be_true
    end
    
    it "食事内容が6の場合はtrueとなる" do
      new_menu = Menu.new(
        :menu_type => 6,
        :detail => "シリアル")
      expect(new_menu.invalid?).to be_true
    end
  end
  
  describe ".valid?" do
    it "食事内容が1〜5の場合はtrueとなる" do
      (1..5).each do |menu_type|
        new_menu = Menu.new(
          :menu_type => menu_type,
          :detail => "シリアル" + menu_type.to_s)
        expect(new_menu.valid?).to be_true
      end
    end
  end
end
