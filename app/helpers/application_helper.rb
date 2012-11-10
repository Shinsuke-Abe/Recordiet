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
    end
  end
end
