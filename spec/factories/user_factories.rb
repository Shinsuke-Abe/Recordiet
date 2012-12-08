# encoding:utf-8
require 'factory_girl'

FactoryGirl.define do
  factory :john, class: User do
    mail_address "john@mail.com"
    display_name "john denver"
    password "pass1234"
  end
  
  factory :eric, class: User do
    mail_address "clapton@cream.com"
    display_name "guitar god"
    password "ocean461"
  end
end
