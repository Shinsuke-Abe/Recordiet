class MilestonesController < ApplicationController
  include ApplicationHelper
  before_filter :required_login
  
  # GET /user/milestone/new
  def new
    @milestone = @user.build_milestone()
  end
  
  # POST /user/milestone/
  def create
    if @milestone = @user.create_milestone(params[:milestone])
      redirect_to weight_logs_path
    else
      render :action => "new"
    end
  end
  
  # GET /user/milestone/edit
  def edit
    @milestone = @user.milestone
  end
  
  # PUT /user/milestone/
  def update
    @milestone = @user.milestone
    
    if @milestone.update_attributes(params[:milestone])
      redirect_to weight_logs_path
    else
      render :action => "edit" 
    end
  end
end
