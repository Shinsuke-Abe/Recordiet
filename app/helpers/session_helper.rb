module SessionHelper
  # filter method to check user logined
  def authenticate_user!
    unless session[:id]
      flash[:notice] = application_message(:login_required)
      redirect_to login_path
    else
      @current_user = User.find(session[:id])
    end
  end
  
  def current_user
    @current_user ||= User.find(session[:id])
  end
end