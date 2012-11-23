class ApplicationController < ActionController::Base
  protect_from_forgery
  include ApplicationHelper
  
  def required_login
    unless session[:id]
      flash[:notice] = application_message(:login_required)
      redirect_to login_path
    else
      @user = User.find(session[:id])
    end
  end
  
  def add_new_line(target, new_line)
    target ? target + "\n" + new_line : new_line
  end
end
