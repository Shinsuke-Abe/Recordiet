# encoding: utf-8
class WeightLogsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_weight_log, :only => [:edit, :update, :destroy]
  after_filter :flash_clear, :only => [:index]
  
  # GET /weight_logs
  def index
    @weight_log = User.find(current_user.id).weight_logs.build
    
    if current_user.weight_logs.empty?
      flash[:notice] = application_message(:weight_log_not_found)
    end
    
    unless current_user.milestone
      flash[:notice] = add_new_line(
        flash[:notice],
        application_message(:milestone_not_found))
    end
  end
  
  # POST /weight_logs
  def create
    @weight_log = User.find(current_user.id).weight_logs.build(params[:weight_log])
    
    unless @weight_log.save
      render :action => "index"
    else
      if @weight_log.achieved?
        flash[:success] = achieve_message(current_user.milestone.reward)
      end
      
      redirect_to weight_logs_path
    end
  end
  
  # GET /weight_logs/edit
  def edit
    # do nothing
  end
  
  # PUT /weight_logs
  def update
    if @weight_log.update_attributes(params[:weight_log])
      redirect_to weight_logs_path
    else
      render :action => "edit" 
    end
  end
  
  # DELETE /weight_logs
  def destroy
    @weight_log.destroy
    
    redirect_to weight_logs_path
  end
  
  private
  def achieve_message(reward)
    sprintf(application_message(:achieve_milestone), reward)
  end
  
  def load_weight_log
    @weight_log = WeightLog.find(params[:id])
  end
end
