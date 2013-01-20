class ApplicationController < ActionController::Base
  protect_from_forgery
  include ApplicationHelper
  include SessionHelper

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
end
