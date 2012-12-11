# encoding:utf-8
require 'factory_girl'

FactoryGirl.define do
  factory :weight_log do
    sequence(:weight) {|n| 75.4 - n}
    sequence(:measured_date) {|n| Date.yesterday - n.days}
    sequence(:fat_percentage) {|n| 24.0 - n}
    association :user, factory: :eric
  end
  
  factory :milestone do
    weight 65.5
    fat_percentage 20.0
    date Date.tomorrow
    reward "寿司"
    association :user, :john
  end
  
  factory :john, class: User do
    mail_address "john@mail.com"
    display_name "john denver"
    password "pass1234"
    
    factory :john_with_milestone do
      after(:create) do |john, evaluator|
        FactoryGirl.create(:milestone, user: john)
      end
    end
  end
  
  factory :eric, class: User do
    mail_address "clapton@cream.com"
    display_name "guitar god"
    password "ocean461"
    
    factory :eric_with_weight_logs do
      ignore do
        weight_logs_count 2
      end
      
      after(:create) do |eric, evaluator|
        FactoryGirl.create_list(:weight_log, evaluator.weight_logs_count, user: eric)
      end
    end
  end
end