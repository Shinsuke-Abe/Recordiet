class MenusController < ApplicationController
  include ApplicationHelper
  before_filter :required_login
  
  def index
    @weight_log = WeightLog.find(params[:weight_log_id])
  end
  
  def new
    @weight_log = WeightLog.find(params[:weight_log_id])
    @menu = @weight_log.menus.build
  end
  
  def create
    @weight_log = WeightLog.find(params[:weight_log_id])
    @menu = @weight_log.menus.create(params[:menu])
    
    if @menu.errors.empty?
      redirect_to weight_logs_path
    else
      render :action => "new"
    end
  end
end
