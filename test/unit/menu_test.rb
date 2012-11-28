# encoding: utf-8
require 'test_helper'

class MenuTest < ActiveSupport::TestCase
  test "食事種類が未入力の場合はエラーとなる" do
    assert_invalidtes_invalid(
      :menu_type => nil,
      :detail => "シリアル")
  end
  
  test "食事内容が未入力の場合はエラーとなる" do
    assert_invalidtes_invalid(
      :menu_type => 1,
      :detail => nil)
  end
  
  test "食事種類が1〜5のいずれかでない場合はエラーとなる" do
    assert_invalidtes_invalid(
      :menu_type => 0,
      :detail => "シリアル")
  end
  
  test "食事内容が1〜5の場合はエラーとならない" do
    (1..5).each do |type|
      new_menu = Menu.new(
        :menu_type => type,
        :detail => "シリアル" + type.to_s)
      assert new_menu.valid?
    end
  end
  
  private
  def assert_invalidtes_invalid(data)
    new_menu = Menu.new(data)
    assert new_menu.invalid?
  end
end
