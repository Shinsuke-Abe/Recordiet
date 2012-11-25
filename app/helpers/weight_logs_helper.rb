#encoding: utf-8
require 'gchart'

module WeightLogsHelper
  def create_chart(weight_logs, milestone)
    unless weight_logs.empty?
      data_arr, axis_arr = chart_arrays weight_logs
      
      chart_arg = chart_basic(data_arr, axis_arr)
      
      if milestone
        chart_arg[:data] << Array.new(data_arr.size, milestone.weight)
        chart_arg[:bar_colors] += ",FF99CC"
        chart_arg[:legend] = ["体重", "目標"]
      end
      
      Gchart.line(chart_arg)
    end
  end
  
  private
  def chart_arrays(weight_logs)
    return weight_logs.reverse.map!{|weight_log| weight_log.weight},
           weight_logs.reverse.map!{|weight_log| weight_log.measured_date.strftime("%m/%d")}
  end
  
  def chart_basic(data_arr, axis_arr)
    chart_arg = {}
    
    chart_arg[:size] = "800x300"
    chart_arg[:bar_colors] = "3300FF"
    chart_arg[:axis_with_labels] = "x"
    
    chart_arg[:data] = [data_arr]
    chart_arg[:axis_labels] = [axis_arr]
    
    chart_arg
  end
end
