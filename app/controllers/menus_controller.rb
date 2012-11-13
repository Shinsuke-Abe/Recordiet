class MenusController < ApplicationController
  before_filter :required_login
  before_filter :get_weight_log
  
  def index
    
  end
  
  def new
    @menu = @weight_log.menus.build
  end
  
  def create
    @menu = @weight_log.menus.create(params[:menu])
    
    if @menu.errors.empty?
      redirect_to weight_logs_path
    else
      render :action => "new"
    end
  end
  
  def edit
    @menu = Menu.find(params[:id])
  end
  
  def update
    @menu = Menu.find(params[:id])
    
    if @menu.update_attributes(params[:menu])
      redirect_to weight_log_menus_path(@weight_log)
    else
      render :action => "edit"
    end
  end
  
  def destroy
    @menu = Menu.find(params[:id])
    @menu.destroy
    
    redirect_to weight_log_menus_path
  end
  
  private
  def get_weight_log
    @weight_log = WeightLog.find(params[:weight_log_id])
  end
end
