# encofing: utf-8
class Admin::NotificationsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :authenticate_admin!
  before_filter :load_notification, :only => [:edit, :update, :destroy]

  def index
    @notifications = Notification.all
  end

  def new
    @notification = Notification.new
  end

  def create
    @notification = Notification.new(params[:notification])

    if @notification.save
      redirect_to admin_notifications_path
    else
      render :action => "new"
    end
  end

  def edit
    # do nothing
  end

  def update
    if @notification.update_attributes(params[:notification])
      redirect_to admin_notifications_path
    else
      render :action => "edit"
    end
  end

  def destroy
    @notification.destroy

    redirect_to admin_notifications_path
  end

  private
  def load_notification
    @notification = Notification.find(params[:id])
  end
end
