# encoding: utf-8
class AchievedMilestoneLogsController < ApplicationController
  before_filter :authenticate_user!
  after_filter :flash_clear

  # GET /achieved_milestone_logs
  def index
    @achieved_milestone_logs = current_user.achieved_milestone_logs

    add_notice application_message :achieved_milestone_not_found if @achieved_milestone_logs.blank?
  end
end
