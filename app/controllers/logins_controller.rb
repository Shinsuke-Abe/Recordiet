# encoding: utf-8
class LoginsController < ApplicationController
  layout "nonavigation"
  after_filter :flash_clear, :only => [:create]
  
  def show
    @user = User.new
  end
  
  def create
    @user = User.new(params[:user])
    
    if authed_user = authenticable?(@user)
      sign_in authed_user
      redirect_to weight_logs_path
    else
      flash[:alert] = application_message(:login_incorrect)
      render :action => "show"
    end
  end
  
  def destroy
    sign_out
    redirect_to login_path
  end
end
