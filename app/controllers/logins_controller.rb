# encoding: utf-8
class LoginsController < ApplicationController
  def show
    @user = User.new
  end
  
  def create
    @user = User.new(params[:user])
    authed_user = User.authenticate(@user.mail_address, @user.password)
    
    if authed_user
      session[:id] = authed_user.id
      redirect_to user_path
    else
      flash[:notice] = "メールアドレスかパスワードが間違っています。"
      render :action => "show"
    end
  end
end
