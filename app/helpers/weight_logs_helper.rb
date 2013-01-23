#encoding: utf-8
require 'gchart'

module WeightLogsHelper
  def create_chart(weight_logs, milestone, data_legend)
    unless weight_logs.blank?
      data_arr, axis_arr = chart_arrays(weight_logs) do |weight_log|
        yield weight_log
      end

      unless data_arr.compact.blank?
        milestone_data = if milestone
          yield milestone
        end

        trim_value = trim_range(data_arr, milestone_data)

        chart_arg = chart_basic(data_arr, axis_arr, trim_value)

        if milestone_data
          chart_arg[:data] << Array.new(data_arr.size, milestone_data - trim_value)
          chart_arg[:bar_colors] += ",FF99CC"
          chart_arg[:legend] = [data_legend, "目標"]
        end

        Gchart.line(chart_arg)
      end
    end
  end

  private
  def chart_arrays(weight_logs)
    reversed_weight_logs = weight_logs.reverse

    [reversed_weight_logs.map{|weight_log| yield weight_log},
     reversed_weight_logs.map{|weight_log| weight_log.measured_date.strftime("%m/%d")}]
  end

  def chart_basic(data_arr, axis_arr, trim_range)
    chart_arg = {}

    chart_arg[:size] = "800x300"
    chart_arg[:bar_colors] = "3300FF"

    chart_arg[:data] = [data_arr.map{|data| data ? data - trim_range : nil}]
    chart_arg[:encoding] = "text"

    chart_arg[:axis_labels] = [axis_arr]
    chart_arg[:axis_with_labels] = ["x", "y"]
    chart_arg[:axis_range] = [nil, [trim_range, data_arr.compact.max, 5]]

    chart_arg
  end

  def trim_range(data_arr, milestone)
    min_value = min_data(data_arr, milestone)

    if min_value <= 10
      0
    else
      ((min_value - 10) / 5).truncate * 5
    end
  end

  def min_data(data_arr, milestone)
    all_data_arr = data_arr.compact

    all_data_arr << milestone if milestone

    all_data_arr.min
  end
end