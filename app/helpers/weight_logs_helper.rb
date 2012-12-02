#encoding: utf-8
require 'gchart'

module WeightLogsHelper
  def create_chart(data_legend)
    unless current_user.weight_logs.empty?
      data_arr, axis_arr = chart_arrays current_user.weight_logs do |weight_log|
        yield weight_log
      end
      
      chart_arg = chart_basic(data_arr, axis_arr)
      
      if current_user.milestone and
         yield current_user.milestone
        milestone = yield current_user.milestone
        chart_arg[:data] << Array.new(data_arr.size, milestone)
        chart_arg[:bar_colors] += ",FF99CC"
        chart_arg[:legend] = [data_legend, "目標"]
      end
      
      Gchart.line(chart_arg)
    end
  end
  
  private
  def chart_arrays(weight_logs)
    return take_off_form_data(weight_logs).reverse.map!{|weight_log| yield weight_log},
           take_off_form_data(weight_logs).reverse.map!{|weight_log| weight_log.measured_date.strftime("%m/%d")}
  end
  
  def chart_basic(data_arr, axis_arr)
    chart_arg = {}
    
    chart_arg[:size] = "800x300"
    chart_arg[:bar_colors] = "3300FF"
    
    chart_arg[:data] = [data_arr]
    chart_arg[:encoding] = "text"
    
    chart_arg[:axis_labels] = [axis_arr]
    chart_arg[:axis_with_labels] = ["x", "y"]
    chart_arg[:axis_range] = [nil, [0, data_arr.max{|a,b| compare_chart_data(a,b)}, 5]]
    
    chart_arg
  end
  
  # データに抜けがある場合のmax値取得のための対処
  def compare_chart_data(a, b)
    if !a and !b
      0
    else
      if !a
        -1
      elsif !b
        1
      else
        a <=> b
      end
    end
  end
end