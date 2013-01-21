# encoding: utf-8
class WeightLogsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_weight_log, :only => [:edit, :update, :destroy]
  before_filter :load_effective_notification, :only => [:index]
  after_filter :flash_clear, :only => [:index]

  # GET /weight_logs
  def index
    # @weight_log = WeightLog.new
    # @weight_logs = current_user.weight_logs.page(params[:page])
    # controllerのあり方
    @weight_log = User.find(current_user.id).weight_logs.build

    if current_user.weight_logs.empty?
      notice_add application_message :weight_log_not_found
    end

    unless current_user.milestone
      notice_add application_message :milestone_not_found
    end
  end

  # POST /weight_logs
  def create
    # @weight_log = current_user.weight_logs.build(params[:weight_log])
    @weight_log = User.find(current_user.id).weight_logs.build(params[:weight_log])

    unless @weight_log.save
      # 上記処理でweight_logsに追加されるのを一覧で表示しないように
      # current_user.reload
      render :action => "index"
    else
      if @weight_log.achieved?
        # TODO milestoneモデルのメソッドにする
        flash[:success] = current_user.milestone.achieve_message
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
  def load_weight_log
    # @weight_log = current_user.weight_logs.find(params[:id])
    @weight_log = WeightLog.find(params[:id])
  end

  def load_effective_notification
    notifications = Notification.effective_notification
    # TODO mapとjoinはモデルの責務として
    unless notifications.empty?
      flash[:system_notification] = notifications.map{|notification| notification.display_content}.join("\n")
    end
  end
end
