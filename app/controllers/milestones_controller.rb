class MilestonesController < ApplicationController
  before_filter :authenticate_user!
  
  # GET /milestone/new
  def new
    @milestone = current_user.build_milestone()
  end
  
  # POST /milestone/
  def create
    @milestone = User.find(current_user.id).build_milestone(params[:milestone])
    
    if @milestone.save
      redirect_to weight_logs_path
    else
      render :action => "new"
    end
  end
  
  # GET /milestone/edit
  def edit
    @milestone = current_user.milestone
  end
  
  # PUT /milestone/
  def update
    @milestone = User.find(current_user.id).milestone
    
    if @milestone.update_attributes(params[:milestone])
      redirect_to weight_logs_path
    else
      render :action => "edit" 
    end
  end
  
  # DELETE /milestone
  def destroy
    current_user.milestone.destroy
    
    if request.referer
      redirect_to :back
    else
      redirect_to weight_logs_path
    end
  end
end
