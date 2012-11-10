# encoding: utf-8
class WeightLogsController < ApplicationController
  include ApplicationHelper
  before_filter :required_login
  
  # show weight logs list logged in user
  def index
    @user = User.find(session[:id])
    
    if @user.weight_logs.empty?
      flash[:notice] = WeightLogsHelper::WEIGHT_LOG_NOT_FOUND
    end
  end
  
  # add weight logs to login user
  def create
    @user = User.find(session[:id])
    @weight_log = @user.weight_logs.create(params[:weight_log])
    
    if @user.milestone and @user.milestone.achieve?(@weight_log)
      @user.achieved_milestone_logs.create(
        :achieved_date => @weight_log.measured_date,
        :milestone_weight => @user.milestone.weight)
      flash[:notice] = sprintf(WeightLogsHelper::ACHIEVE_MILESTONE, @user.milestone.reward)
    end
    
    render :action => "index"
  end
  
  # show weight_log edit form
  def edit
    @weight_log = WeightLog.find(params[:id])
  end
  
  # update weight_log
  def update
    @weight_log = WeightLog.find(params[:id])
    
    if @weight_log.update_attributes(params[:weight_log])
      redirect_to weight_logs_path
    else
      render :action => "edit" 
    end
  end
  
  # delete weight_log
  def destroy
    @weight_log = WeightLog.find(params[:id])
    @weight_log.destroy
    
    redirect_to weight_logs_path
  end
end
