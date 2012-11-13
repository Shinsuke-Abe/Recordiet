class AchievedMilestoneLogsController < ApplicationController
  before_filter :required_login
  
  def index
    @achieved_milestone_logs = @user.achieved_milestone_logs
  end
end
