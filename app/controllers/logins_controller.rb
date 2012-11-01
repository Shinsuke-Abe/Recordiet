# encoding: utf-8
class LoginsController < ApplicationController
  def show
    @user = User.new
  end
  
  def create
    @user = User.new(params[:user])
    if User.authenticate(@user.mail_address, @user.password)
      session[:mail_address] = "john@mail.com"
      redirect_to user_path
    else
      flash[:notice] = "メールアドレスかパスワードが間違っています。"
      render :action => "show"
    end
  end
end
