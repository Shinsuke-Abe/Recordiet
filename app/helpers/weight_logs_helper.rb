#encoding: utf-8
require 'gchart'

module WeightLogsHelper
  def create_weight_chart
    unless current_user.weight_logs.empty?
      data_arr, axis_arr = chart_weight_arrays take_off_form_data(current_user.weight_logs)
      
      chart_arg = chart_basic(data_arr, axis_arr)
      
      if current_user.milestone
        chart_arg[:data] << Array.new(data_arr.size, current_user.milestone.weight)
        chart_arg[:bar_colors] += ",FF99CC"
        chart_arg[:legend] = ["体重", "目標"]
      end
      
      Gchart.line(chart_arg)
    end
  end
  
  def create_fat_percentage_chart
    unless current_user.weight_logs.empty?
      data_arr, axis_arr = chart_fat_percentage_arrays take_off_form_data(current_user.weight_logs)
      
      chart_arg = chart_basic(data_arr, axis_arr)
      
      if current_user.milestone and
         current_user.milestone.fat_percentage
        chart_arg[:data] << Array.new(data_arr.size, current_user.milestone.fat_percentage)
        chart_arg[:bar_colors] += ",FF99CC"
        chart_arg[:legend] = ["体脂肪率", "目標"]
      end
      
      Gchart.line(chart_arg)
    end
  end
  
  private
  def chart_weight_arrays(weight_logs)
    return weight_logs.reverse.map!{|weight_log| weight_log.weight},
           weight_logs.reverse.map!{|weight_log| weight_log.measured_date.strftime("%m/%d")}
  end
  
  def chart_fat_percentage_arrays(weight_logs)
    return weight_logs.reverse.map!{|weight_log| weight_log.fat_percentage},
           weight_logs.reverse.map!{|weight_log| weight_log.measured_date.strftime("%m/%d")}
  end
  
  def chart_basic(data_arr, axis_arr)
    chart_arg = {}
    
    chart_arg[:size] = "800x300"
    chart_arg[:bar_colors] = "3300FF"
    
    chart_arg[:data] = [data_arr]
    chart_arg[:encoding] = "text"
    
    chart_arg[:axis_labels] = [axis_arr]
    chart_arg[:axis_with_labels] = ["x", "y"]
    chart_arg[:axis_range] = [nil, [0, data_arr.max, 5]]
    
    chart_arg
  end
end
