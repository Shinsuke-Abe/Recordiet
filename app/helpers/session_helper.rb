module SessionHelper
  # filter method to check user logined
  def authenticate_user!
    unless signed_in?
      flash[:notice] = application_message(:login_required)
      redirect_to login_path
    else
      current_user
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
  
  def sign_out
    session[:id] = nil
  end
  
  def authenticable?(user)
    User.authenticate(user.mail_address, user.password)
  end
  
  def signed_in?
    session[:id]
  end
end