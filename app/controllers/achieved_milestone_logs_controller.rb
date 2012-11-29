# encoding: utf-8
class AchievedMilestoneLogsController < ApplicationController
  before_filter :authenticate_user!
  after_filter :flash_clear
  
  # GET /achieved_milestone_logs
  def index
    @achieved_milestone_logs = current_user.achieved_milestone_logs
    
    if !@achieved_milestone_logs or @achieved_milestone_logs.empty?
      flash[:notice] = application_message(:achieved_milestone_not_found)
    end
  end
end
