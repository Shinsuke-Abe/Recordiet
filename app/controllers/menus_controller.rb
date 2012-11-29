class MenusController < ApplicationController
  before_filter :authenticate_user!
  include MenusHelper
  
  # GET /weight_logs/:id/menu
  def index
    # do nothing
  end
  
  # GET /weight_logs/:id/menu/new
  def new
    @menu = current_weight_log.menus.build
  end
  
  # POST /weight_logs/:id/menu
  def create
    @menu = current_weight_log.menus.build(params[:menu])
    
    if @menu.save
      redirect_to weight_logs_path
    else
      render :action => "new"
    end
  end
  
  # GET /weight_logs/:id/menu/edit/:id
  def edit
    @menu = current_menu
  end
  
  # PUT /weight_logs/:id/menu
  def update
    @menu = current_menu
    
    if @menu.update_attributes(params[:menu])
      redirect_to weight_log_menus_path(current_weight_log)
    else
      render :action => "edit"
    end
  end
  
  # DELETE /weight_logs/:id/menu/:id
  def destroy
    current_menu.destroy
    
    redirect_to weight_log_menus_path
  end
  
  private
  def current_menu
    Menu.find(params[:id])
  end
end
