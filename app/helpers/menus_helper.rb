# encoding: utf-8
module MenusHelper

  def display_menu_type(type)
    menu_type_hash[type]
  end
  
  def menu_type_hash
    {
      1 => "朝食",
      2 => "昼食",
      3 => "夕食",
      4 => "間食",
      5 => "その他"
    }
  end
  
  def select_menu_array
    menu_type_hash.invert.to_a
  end
end
