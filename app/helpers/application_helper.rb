# encoding: utf-8
module ApplicationHelper
  def take_off_form_data(weight_logs)
    weight_logs.select { |log|
      log.id != nil
    }
  end
  
  def required_login
    unless session[:id]
      flash[:notice] = "Recordietの各機能を使うにはログインが必要です。"
      redirect_to login_path
    else
      @user = User.find(session[:id])
    end
  end
  
  def add_new_line(target, new_line)
    target ? target + "\n" + new_line : new_line
  end
  
  def application_message(symbol)
    t symbol, :scope => :application_messages
  end
  
  def page_title(controller)
    t(controller.controller_name, :scope => :controllers) +
    t(controller.action_name, :scope => :actions, :default => "")
  end
end
