# encoding: utf-8
class LoginsController < ApplicationController
  layout "nonavigation"
  
  def show
    @user = User.new
  end
  
  def create
    @user = User.new(params[:user])
    authed_user = User.authenticate(@user.mail_address, @user.password)
    
    if authed_user
      session[:id] = authed_user.id
      redirect_to weight_logs_path
    else
      flash[:alert] = LoginsHelper::INCORRECT_LOGIN_INFORMATION
      render :action => "show"
    end
  end
  
  def destroy
    session[:id] = nil
    redirect_to login_path
  end
end
