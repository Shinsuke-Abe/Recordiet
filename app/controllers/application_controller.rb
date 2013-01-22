class ApplicationController < ActionController::Base
  protect_from_forgery
  include ApplicationHelper

  helper_method :current_user

  # filter method to clear flash
  # for use flash in render action
  def flash_clear
    flash[:notice] = nil
    flash[:alert] = nil
  end

  def notice_add(new_line)
    unless flash[:notice]
      flash[:notice] = new_line
    else
      flash[:notice] << "\n" << new_line
    end
  end

  def add_new_line(target, new_line)
    target ? target + "\n" + new_line : new_line
  end

  private
  # filter method to check user logined
  def authenticate_user!
    unless signed_in?
      flash[:notice] = application_message(:login_required)
      redirect_to login_path
    else
      current_user
    end
  end

  def authenticate_admin!
    unless sined_in_as_admin?
      redirect_to admin_confirm_path
    end
  end

  def current_user
    @current_user ||= User.find(session[:id])
  end

  def sign_in(user)
    if authed_user = authenticable?(user)
      session[:id] = authed_user.id
      current_user
    end
  end

  def sign_in_as_admin(mail_address, password)
    if authed_user = authenticable?(:mail_address => mail_address, :password => password)
      session[:is_administrator] = authed_user.is_administrator
      authed_user
    end
  end

  def sign_out
    session[:id] = nil
    session[:is_administrator] = nil
  end

  def authenticable?(user)
    if user.is_a? User
      User.authenticate(user.mail_address, user.password)
    elsif user.is_a? Hash
      User.authenticate(user[:mail_address], user[:password])
    end
  end

  def signed_in?
    session[:id]
  end

  def sined_in_as_admin?
    session[:is_administrator]
  end
end
