class AchievedMilestoneLogsController < ApplicationController
  include ApplicationHelper
  before_filter :required_login
  
  def index
    @user = User.find(session[:id])
    @achieved_milestone_logs = @user.achieved_milestone_logs
  end
end
