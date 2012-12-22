# encoding: utf-8
require 'spec_helper'

describe WeightLogsHelper do
	before do
		@eric = FactoryGirl.create(:eric_with_weight_logs)
		@eric.create_milestone(
			:weight => 60.0,
			:fat_percentage => 15.5,
			:date => Date.today + 90.days)
	end

	it "目標のある体重履歴でグラフを作成する" do
		chart_url = create_chart(@eric, "体重") do |data|
			data.weight
		end

		expect(chart_url.include? "chco=3300FF,FF99CC").to be_true
		expect(chart_url.include? chart_date_axis_label(@eric.weight_logs)).to be_true
		expect(chart_url.include? chart_data_scale(@eric.weight_logs)).to be_true
		expect(chart_url.include? chart_legend(true)).to be_true
		expect(chart_url.include? chart_range(@eric.weight_logs)).to be_true
		expect(chart_url.include? chart_datas(@eric.weight_logs, @eric.milestone.weight)).to be_true
	end

	def chart_date_axis_label(weight_logs)
		axis_label_arr = weight_logs.reverse.map do |weight_log|
			weight_log.measured_date.month.to_s + "%2F" +
			weight_log.measured_date.day.to_s
		end

		sprintf("chxl=0:|%s", axis_label_arr.join("|"))
	end

	def chart_data_scale(weight_logs)
		sprintf("chds=0,%s", max_data(weight_logs))
	end

	def chart_legend(has_milestone)
		if has_milestone
			sprintf("chdl=%s|%s", URI.escape("体重"), URI.escape("目標"))
		else
			sprintf("chdl=%s", URI.escape("体重"))
		end
	end

	def chart_range(weight_logs)
		sprintf("chxr=1,0,%s,5", max_data(weight_logs))
	end

	def chart_datas(weight_logs, milestone_weight)
		data_arr = weight_logs.reverse.map{ |weight_log| weight_log.weight }
		milestone_arr = Array.new(data_arr.length, milestone_weight)

		sprintf("chd=t:%s|%s", data_arr.join(","), milestone_arr.join(","))
	end

	def max_data(weight_logs)
		weight_logs.map{ |weight_log| weight_log.weight}.max
	end
end