# encoding: utf-8
class WeightLogsController < ApplicationController
  # add weight logs to login user
  def create
    @user = User.find(session[:id])
    @weight_log = @user.weight_logs.create(params[:weight_log])
    
    if @weight_log.errors
      flash[:notice] = "記録の登録には計測日と体重が必要です。"
    end
    
    redirect_to user_path
  end
  
  # show weight_log edit form
  def edit
    @weight_log = WeightLog.find(params[:id])
  end
  
  # update weight_log
  def update
    @weight_log = WeightLog.find(params[:id])
    
    unless @weight_log.update_attributes(params[:weight_log])
      flash[:notice] = "記録の登録には計測日と体重が必要です。"
    end
    
    redirect_to user_path
  end
  
  # delete weight_log
  def destroy
    @weight_log = WeightLog.find(params[:id])
    @weight_log.destroy
    
    redirect_to user_path
  end
end
