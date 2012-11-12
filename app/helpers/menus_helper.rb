# encoding: utf-8
module MenusHelper
  def display_menu_type(type)
    menu_types = {
      1 => "朝食",
      2 => "昼食",
      3 => "夕食",
      4 => "間食",
      5 => "その他"
    }
    menu_types[type]
  end
end
