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
  
  def edit
    @weight_log = WeightLog.find(params[:weight_log_id])
    @menu = Menu.find(params[:id])
  end
  
  def update
    @weight_log = WeightLog.find(params[:weight_log_id])
    @menu = Menu.find(params[:id])
    
    if @menu.update_attributes(params[:menu])
      redirect_to weight_log_menus_path(@weight_log)
    else
      render :action => "edit"
    end
  end
  
  def destroy
    @weight_log = WeightLog.find(params[:weight_log_id])
    @menu = Menu.find(params[:id])
    @menu.destroy
    
    redirect_to weight_log_menus_path
  end
end
