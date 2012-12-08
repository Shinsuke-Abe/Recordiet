# encoding:utf-8
require 'factory_girl'

FactoryGirl.define do
  factory :eric_yesterday_log, class: WeightLog do
    measured_date Date.yesterday
    weight 74.9
    fat_percentage 19.8
    association :user, factory: :eric
  end
  
  factory :eric_2days_ago_log, class: WeightLog do
    measured_date Date.yesterday - 1.day
    weight 75.0
    fat_percentage 21.0
    association :user, factory: :eric
  end
end