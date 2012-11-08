# encoding: utf-8
class WeightLogsController < ApplicationController
  # add weight logs to login user
  def create
    @user = User.find(session[:id])
    @weight_log = @user.weight_logs.create(params[:weight_log])
    
    if !@weight_log.errors.empty?
      flash[:notice] = "記録の登録には計測日と体重が必要です。"
    elsif @user.milestone and @user.milestone.achieve?(@weight_log)
      @user.achieved_milestone_logs.create(
        :achieved_date => @weight_log.measured_date,
        :milestone_weight => @user.milestone.weight)
      flash[:notice] = "目標を達成しました！おめでとうございます。<br/>ご褒美は#{@user.milestone.reward}です、楽しんで下さい！"
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
    
    if @weight_log.update_attributes(params[:weight_log])
      redirect_to user_path
    else
      flash[:notice] = "記録の登録には計測日と体重が必要です。"
      render :action => "edit" 
    end
  end
  
  # delete weight_log
  def destroy
    @weight_log = WeightLog.find(params[:id])
    @weight_log.destroy
    
    redirect_to user_path
  end
end
