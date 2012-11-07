class MilestonesController < ApplicationController
  # /user/milestone/new
  def new
    @user = User.find(session[:id])
    @milestone = @user.build_milestone()
  end
end
