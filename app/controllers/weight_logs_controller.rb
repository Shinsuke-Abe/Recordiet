# encoding: utf-8
class WeightLogsController < ApplicationController
  include WeightLogsHelper
  before_filter :required_login
  after_filter :flash_clear, :only => [:index]
  
  # show weight logs list logged in user
  def index
    if @user.weight_logs.empty?
      flash[:notice] = application_message(:weight_log_not_found)
    end
    
    unless @user.milestone
      flash[:notice] = add_new_line(
        flash[:notice],
        application_message(:milestone_not_found))
    end
  end
  
  # add weight logs to login user
  def create
    @weight_log = @user.weight_logs.create(params[:weight_log])
    
    unless @weight_log.errors.empty?
      render :action => "index"
    else
      if @weight_log.achieve?(@user.milestone)
        @user.achieved_milestone_logs.create(
          :achieved_date => @weight_log.measured_date,
          :milestone_weight => @user.milestone.weight)
          
        flash[:success] = achieve_message(@user.milestone.reward)
      end
      
      redirect_to weight_logs_path
    end
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
