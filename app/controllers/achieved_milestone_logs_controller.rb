class AchievedMilestoneLogsController < ApplicationController
  def index
    @user = User.find(session[:id])
    @achieved_milestone_logs = @user.achieved_milestone_logs
  end
end
