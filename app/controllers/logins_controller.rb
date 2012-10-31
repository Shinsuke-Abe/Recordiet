# encofing: utf-8
class LoginsController < ApplicationController
  def show
    @user = User.new
  end
  
  def create
    session[:mail_address] = "john@mail.com"
    redirect_to user_path
  end
end
