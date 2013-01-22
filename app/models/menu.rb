# encoding: utf-8
class Menu < ActiveRecord::Base
  belongs_to :weight_log
  attr_accessible :detail, :menu_type

  validates :menu_type, :detail, :presence => true
  validates :menu_type, :inclusion => { :in => 1..5 }

  @@menu_types = {
    1 => "朝食",
    2 => "昼食",
    3 => "夕食",
    4 => "間食",
    5 => "その他"
  }.freeze

  def self.display_menu_type(type)
    @@menu_types[type]
  end

  def self.select_menu_array
    @@menu_types.invert.to_a
  end
end
