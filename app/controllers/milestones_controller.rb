class MilestonesController < ApplicationController
  before_filter :authenticate_user!
  
  # GET /user/milestone/new
  def new
    @milestone = current_user.build_milestone()
  end
  
  # POST /user/milestone/
  def create
    @milestone = current_user.build_milestone(params[:milestone])
    if @milestone.save
      redirect_to weight_logs_path
    else
      render :action => "new"
    end
  end
  
  # GET /user/milestone/edit
  def edit
    @milestone = current_user.milestone
  end
  
  # PUT /user/milestone/
  def update
    @milestone = current_user.milestone
    
    if @milestone.update_attributes(params[:milestone])
      redirect_to weight_logs_path
    else
      render :action => "edit" 
    end
  end
  
  def destroy
    @milestone = current_user.milestone
    @milestone.destroy
    
    if request.referer
      redirect_to :back
    else
      redirect_to weight_logs_path
    end
  end
end
