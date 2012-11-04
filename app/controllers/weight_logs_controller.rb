class WeightLogsController < ApplicationController
  # add weight logs to login user
  def create
    @user = User.find(session[:id])
    @weight_log = @user.weight_logs.create!(params[:weight_log])
    redirect_to user_path
  end
end
