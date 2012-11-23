class ApplicationController < ActionController::Base
  protect_from_forgery
  include ApplicationHelper
  
  # filter method to check user logined
  def required_login
    unless session[:id]
      flash[:notice] = application_message(:login_required)
      redirect_to login_path
    else
      @user = User.find(session[:id])
    end
  end
  
  # filter method to clear flash
  # for use flash in render action
  def flash_clear
    flash[:notice] = nil
    flash[:alert] = nil
  end
  
  def add_new_line(target, new_line)
    target ? target + "\n" + new_line : new_line
  end
end
