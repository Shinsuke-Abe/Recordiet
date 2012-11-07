class MilestonesController < ApplicationController
  # GET /user/milestone/new
  def new
    @user = User.find(session[:id])
    @milestone = @user.build_milestone()
  end
  
  # POST /user/milestone/
  def create
    @user = User.find(session[:id])
    if @milestone = @user.create_milestone(params[:milestone])
      redirect_to user_path
    else
      render :action => "new"
    end
  end
  
  # GET /user/milestone/edit
  def edit
    @user = User.find(session[:id])
    @milestone = @user.milestone
  end
end
