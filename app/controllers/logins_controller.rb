# encoding: utf-8
class LoginsController < ApplicationController
  layout "nonavigation"
  after_filter :flash_clear, :only => [:create]
  
  # GET /login
  def show
    @user = User.new
  end
  
  # POST /login
  def create
    @user = User.new(params[:user])
    
    if sign_in @user
      redirect_to weight_logs_path
    else
      flash[:alert] = application_message(:login_incorrect)
      render :action => "show"
    end
  end
  
  # DELETE /login
  def destroy
    sign_out
    redirect_to login_path
  end
end
