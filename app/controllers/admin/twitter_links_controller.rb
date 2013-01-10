class Admin::TwitterLinksController < ApplicationController
  before_filter :authenticate_user!
  before_filter :authenticate_admin!

  def show
    unless @twitter_link = TwitterLink.find(:first)
      @twitter_link = TwitterLink.new
    end
  end

  def create
  end

  def update
  end
end
