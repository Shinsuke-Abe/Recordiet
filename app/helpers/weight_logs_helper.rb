#encoding: utf-8
require 'gchart'

module WeightLogsHelper
  def create_chart(user, data_legend, page_no)
    unless user.weight_logs.empty?
      p "チャート生成開始"
      data_arr, axis_arr = chart_arrays(user, page_no) do |weight_log|
        yield weight_log
      end

      p "データ取得完了"
      p data_arr
      unless data_arr.select{|data| data}.empty?
        p "チャート描画開始"
        trim_value = trim_range(data_arr, user) do |milestone|
          yield milestone
        end

        p "トリム"
        p trim_value
        chart_arg = chart_basic(data_arr, axis_arr, trim_value)

        if user.milestone and
           yield user.milestone
          milestone = yield user.milestone
          chart_arg[:data] << Array.new(data_arr.size, milestone - trim_value)
          chart_arg[:bar_colors] += ",FF99CC"
          chart_arg[:legend] = [data_legend, "目標"]
        end

        Gchart.line(chart_arg)
      end
    end
  end

  private
  def chart_arrays(user, page_no)
    return user.weight_logs.page(page_no).reverse.map{|weight_log| yield weight_log},
           user.weight_logs.page(page_no).reverse.map{|weight_log| weight_log.measured_date.strftime("%m/%d")}
  end

  def chart_basic(data_arr, axis_arr, trim_range)
    chart_arg = {}

    chart_arg[:size] = "800x300"
    chart_arg[:bar_colors] = "3300FF"

    chart_arg[:data] = [data_arr.map{|data| data ? data - trim_range : nil}]
    chart_arg[:encoding] = "text"

    chart_arg[:axis_labels] = [axis_arr]
    chart_arg[:axis_with_labels] = ["x", "y"]
    chart_arg[:axis_range] = [nil, [trim_range, data_arr.select{ |data| data}.max, 5]]

    chart_arg
  end

  def trim_range(data_arr, user)
    min_value = min_data(data_arr, user) do |milestone|
      yield milestone
    end

    if min_value <= 10
      0
    else
      ((min_value - 10) / 5).truncate * 5
    end
  end

  def min_data(data_arr, user)
    all_data_arr = data_arr.select{|data| data}

    if user.milestone and
      yield user.milestone
      milestone = yield user.milestone
      all_data_arr << milestone
    end

    all_data_arr.min
  end
end