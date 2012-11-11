# encoding: utf-8
require 'test_helper'

class MenuTest < ActiveSupport::TestCase
  test "食事種類が未入力の場合はエラーとなる" do
    new_menu = Menu.new(
      :type => nil,
      :detail => "シリアル")
    assert new_menu.invalid?
  end
  
  test "食事内容が未入力の場合はエラーとなる" do
    new_menu = Menu.new(
      :type => 1,
      :detail => nil)
    assert new_menu.invalid?
  end
  
  test "食事種類が1〜5のいずれかでない場合はエラーとなる" do
    new_menu = Menu.new(
      :type => 0,
      :detail => "シリアル")
    assert new_menu.invalid?
  end
  
  test "食事内容が1〜5の場合はエラーとならない" do
    (1..5).each do |type|
      new_menu = Menu.new(
        :type => type,
        :detail => "シリアル" + type.to_s)
    end
  end
end
