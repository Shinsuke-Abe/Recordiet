# encoding: utf-8
class AchievedMilestoneLogsController < ApplicationController
  include AchievedMilestoneLogsHelper
  before_filter :required_login
  after_filter :flash_clear
  
  def index
    @achieved_milestone_logs = @user.achieved_milestone_logs
    
    if !@achieved_milestone_logs or @achieved_milestone_logs.empty?
      flash[:notice] = AchievedMilestoneLogsHelper::ACHIEVED_MILESTONE_NOT_FOUND
    end
  end
  
  private 
  def flash_clear
    flash[:notice] = nil
  end
end
