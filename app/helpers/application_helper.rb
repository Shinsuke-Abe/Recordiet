# encoding: utf-8
module ApplicationHelper
  def take_off_form_data(weight_logs)
    weight_logs.select{ |log| log.id }
  end
  
  def application_message(symbol)
    t symbol, :scope => :application_messages
  end
  
  def page_title(controller)
    t(controller.controller_name, :scope => :controllers) +
    t(controller.action_name, :scope => :actions, :default => "")
  end
end
