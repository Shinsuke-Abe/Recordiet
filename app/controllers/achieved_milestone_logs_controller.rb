# encoding: utf-8
class AchievedMilestoneLogsController < ApplicationController
  before_filter :required_login
  after_filter :flash_clear
  
  def index
    @achieved_milestone_logs = @user.achieved_milestone_logs
    
    if !@achieved_milestone_logs or @achieved_milestone_logs.empty?
      flash[:notice] = application_message(:achieved_milestone_not_found)
    end
  end
end
