class MilestonesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_milestone, :only => [:edit, :update, :destroy]

  # GET /milestone/new
  def new
    # TODO form => @milestone || Milestone.new
    @milestone = User.find(current_user.id).build_milestone
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
    # do nothing
  end

  # PUT /milestone/
  def update
    if @milestone.update_attributes(params[:milestone])
      redirect_to weight_logs_path
    else
      render :action => "edit"
    end
  end

  # DELETE /milestone
  def destroy
    @milestone.destroy

    if request.referer
      redirect_to :back
    else
      redirect_to weight_logs_path
    end
  end

  private
  def load_milestone
    @milestone = User.find(current_user.id).milestone
  end
end
