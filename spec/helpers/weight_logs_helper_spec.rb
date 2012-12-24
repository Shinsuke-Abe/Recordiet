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
		chart_url = create_chart(@eric, "体重", nil) do |data|
			data.weight
		end

		trim_range_num = expected_trim_range(@eric.weight_logs.page(nil), @eric.milestone.weight)

		expect(chart_url.include? "chco=3300FF,FF99CC").to be_true
		expect(chart_url.include? chart_date_axis_label(@eric.weight_logs.page(nil))).to be_true
		expect(chart_url.include? chart_legend(true)).to be_true
		expect(chart_url.include? chart_range(trim_range_num, @eric.weight_logs.page(nil))).to be_true
		expect(chart_url.include? chart_datas(@eric.weight_logs.page(nil), @eric.milestone.weight, trim_range_num)).to be_true
	end

	it "ページを指定してグラフを作成する" do
	  FactoryGirl.create_list(:weight_log, 17, user: @eric)

	  chart_url = create_chart(@eric, "体重", 2) do |data|
	  	data.weight
	  end

	  trim_range_num = expected_trim_range(@eric.weight_logs.page(2), @eric.milestone.weight)

	  expect(chart_url.include? "chco=3300FF,FF99CC").to be_true
	  expect(chart_url.include? chart_date_axis_label(@eric.weight_logs.page(2))).to be_true
	  expect(chart_url.include? chart_legend(true)).to be_true
	  expect(chart_url.include? chart_range(trim_range_num, @eric.weight_logs.page(2))).to be_true
	  expect(chart_url.include? chart_datas(@eric.weight_logs.page(2), @eric.milestone.weight, trim_range_num)).to be_true
	end

	after do
		FactoryGirl.reload
	end

	def chart_date_axis_label(weight_logs)
		axis_label_arr = weight_logs.reverse.map do |weight_log|
			weight_log.measured_date.strftime("%m") + "%2F" +
			weight_log.measured_date.strftime("%d")
		end

		sprintf("chxl=0:|%s", axis_label_arr.join("|"))
	end

	def chart_legend(has_milestone)
		if has_milestone
			sprintf("chdl=%s|%s", URI.escape("体重"), URI.escape("目標"))
		else
			sprintf("chdl=%s", URI.escape("体重"))
		end
	end

	def chart_range(trim_range, weight_logs)
		sprintf("chxr=1,%s,%s,5", trim_range, max_data(weight_logs))
	end

	def chart_datas(weight_logs, milestone_weight, trim_range)
		data_arr = weight_logs.reverse.map{ |weight_log| weight_log.weight - trim_range }
		milestone_arr = Array.new(data_arr.length, milestone_weight - trim_range)

		sprintf("chd=t:%s|%s", data_arr.join(","), milestone_arr.join(","))
	end

	def max_data(weight_logs)
		weight_logs.map{ |weight_log| weight_log.weight}.max
	end

	def expected_trim_range(weight_logs, milestone_weight)
		min_value = (weight_logs.map{|weight_log| weight_log.weight} << milestone_weight).min
		((min_value - 10) / 5).truncate * 5
	end
end