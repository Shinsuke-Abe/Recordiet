# encoding: utf-8
require 'test_helper'

class WeightLogsHelperTest < ActionView::TestCase
  fixtures :all
  test "目標のある体重履歴でグラフを作成する" do
    eric = users(:eric)
    chart_url = create_chart(eric, "体重") { |data| data.weight }
    
    assert chart_url.include? sprintf("chxl=0:|%s|%s", weight_logs(:one).measured_date.month.to_s + "%2F" + weight_logs(:one).measured_date.day.to_s, weight_logs(:two).measured_date.month.to_s + "%2F" + weight_logs(:two).measured_date.day.to_s)
    assert chart_url.include? "chco=3300FF,FF99CC"
    assert chart_url.include? "chds=0,75.0"
    assert chart_url.include? sprintf("chdl=%s|%s", URI.escape("体重"), URI.escape("目標"))
    assert chart_url.include? "chxr=1,0,75.0,5"
    assert chart_url.include? "chd=t:74.9,75.0|1.5,1.5"
  end
end
