class LoginsController < ApplicationController
  def show
    
  end
  
  def create
    session[:mail_address] = "john@mail.com"
    redirect_to user_path
  end
end
