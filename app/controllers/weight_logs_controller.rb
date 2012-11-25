# encoding: utf-8
require 'gchart'

class WeightLogsController < ApplicationController
  before_filter :authenticate_user!
  after_filter :flash_clear, :only => [:index]
  
  # show weight logs list logged in user
  def index
    if current_user.weight_logs.empty?
      flash[:notice] = application_message(:weight_log_not_found)
    else
      data_arr = current_user.weight_logs.reverse.map!{|weight_log| weight_log.weight}
      axis_arr = current_user.weight_logs.reverse.map!{|weight_log| weight_log.measured_date.strftime("%m/%d")}
      if current_user.milestone
        @weight_log_chart = Gchart.line(
          :size => '800x300',
          :data => [data_arr, Array.new(data_arr.size, current_user.milestone.weight)],
          :bar_colors => '3300FF,FF99CC',
          :legend => ["体重", "目標"],
          :axis_with_labels => 'x',
          :axis_labels => [axis_arr])
      else
        @weight_log_chart = Gchart.line(
          :size => '800x300',
          :data => [data_arr],
          :bar_colors => '3300FF',
          :axis_with_labels => 'x',
          :axis_labels => [axis_arr])
      end
    end
    
    unless current_user.milestone
      flash[:notice] = add_new_line(
        flash[:notice],
        application_message(:milestone_not_found))
    end
  end
  
  # add weight logs to login user
  def create
    @weight_log = current_user.weight_logs.build(params[:weight_log])
    
    unless @weight_log.save
      render :action => "index"
    else
      if @weight_log.achieved?
        flash[:success] = achieve_message(current_user.milestone.reward)
      end
      
      redirect_to weight_logs_path
    end
  end
  
  # show weight_log edit form
  def edit
    @weight_log = current_weight_log
  end
  
  # update weight_log
  def update
    @weight_log = current_weight_log
    
    if @weight_log.update_attributes(params[:weight_log])
      redirect_to weight_logs_path
    else
      render :action => "edit" 
    end
  end
  
  # delete weight_log
  def destroy
    current_weight_log.destroy
    
    redirect_to weight_logs_path
  end
  
  private
  def achieve_message(reward)
    sprintf(application_message(:achieve_milestone), reward)
  end
  
  def current_weight_log
    WeightLog.find(params[:id])
  end
end
