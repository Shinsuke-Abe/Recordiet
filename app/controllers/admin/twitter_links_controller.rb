class Admin::TwitterLinksController < ApplicationController
  before_filter :authenticate_user!
  before_filter :authenticate_admin!

  # TODO 設定の取得はEnvを使う
  # TODO modelの削除
  # TODO modelのテストを削除
  # TODO controllerのspecで確認

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
