# encoding:utf-8
require 'factory_girl'
require 'spec_helper'

FactoryGirl.define do
  factory :john, class: User do
    mail_address "john@mail.com"
    display_name "john denver"
    password "pass1234"
  end
end
