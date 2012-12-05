class MenusController < ApplicationController
  before_filter :authenticate_user!
  before_filter :current_menu, :only => [:edit, :update, :destroy]
  before_filter :build_menu, :only => [:new, :create]
  include MenusHelper
  
  # GET /weight_logs/:id/menu
  def index
    # do nothing
  end
  
  # GET /weight_logs/:id/menu/new
  def new
    # do nothing
  end
  
  # POST /weight_logs/:id/menu
  def create
    if @menu.save
      redirect_to weight_logs_path
    else
      render :action => "new"
    end
  end
  
  # GET /weight_logs/:id/menu/edit/:id
  def edit
    # do nothing
  end
  
  # PUT /weight_logs/:id/menu
  def update
    if @menu.update_attributes(params[:menu])
      redirect_to weight_log_menus_path(current_weight_log)
    else
      render :action => "edit"
    end
  end
  
  # DELETE /weight_logs/:id/menu/:id
  def destroy
    @menu.destroy
    
    redirect_to weight_log_menus_path
  end
  
  private
  def current_menu
    @menu = Menu.find(params[:id])
  end
  
  def build_menu
    @menu = current_weight_log.menus.build(params[:menu])
  end
end
