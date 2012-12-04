#encoding: utf-8
require 'gchart'

module WeightLogsHelper
  def create_chart(user, data_legend)
    unless user.weight_logs.empty?
      data_arr, axis_arr = chart_arrays user do |weight_log|
        yield weight_log
      end
      
      chart_arg = chart_basic(data_arr, axis_arr)
      
      if user.milestone and
         yield user.milestone
        milestone = yield user.milestone
        chart_arg[:data] << Array.new(data_arr.size, milestone)
        chart_arg[:bar_colors] += ",FF99CC"
        chart_arg[:legend] = [data_legend, "目標"]
      end
      
      Gchart.line(chart_arg)
    end
  end
  
  private
  def chart_arrays(user)
    return user.fixed_weight_logs.reverse.map{|weight_log| yield weight_log},
           user.fixed_weight_logs.reverse.map{|weight_log| weight_log.measured_date.strftime("%m/%d")}
  end
  
  def chart_basic(data_arr, axis_arr)
    chart_arg = {}
    
    chart_arg[:size] = "800x300"
    chart_arg[:bar_colors] = "3300FF"
    
    chart_arg[:data] = [data_arr]
    chart_arg[:encoding] = "text"
    
    chart_arg[:axis_labels] = [axis_arr]
    chart_arg[:axis_with_labels] = ["x", "y"]
    chart_arg[:axis_range] = [nil, [0, data_arr.select{ |data| data}.max, 5]]
    
    chart_arg
  end
end