# encoding: utf-8

require 'spec_helper'

describe MenusController do
  describe "POST weight_logs/:weight_log_id/menu" do
    before do
      @eric = FactoryGirl.create(:eric_with_weight_logs)
      session[:id] = @eric.id
    end

    it "正常に食事内容を登録できた場合は体重履歴ページにリダイレクトする" do
      post :create, :weight_log_id => @eric.weight_logs[0].id, :menu => {
        :menu_type => 1,
        :detail => "テスト食事"
      }

      response.should redirect_to weight_logs_path
    end

    it "食事内容登録でエラーが発生した場合は登録フォームが再表示される" do
      post :create, :weight_log_id => @eric.weight_logs[0].id, :menu => {
        :menu_type => nil,
        :detail => nil
      }

      response.should render_template "new"
    end
  end

  describe "PUT weight_logs/:weight_log_id/menu/:id" do
    before do
      @eric = FactoryGirl.create(:eric_with_weight_logs_with_menu)
      session[:id] = @eric.id
    end

    it "正常に食事内容を変更できた場合は食事履歴ページにリダイレクトする" do
      put :update, :weight_log_id => @eric.weight_logs[1].id, :id => @eric.weight_logs[1].menus[0].id, :menu => {
        :menu_type => 3,
        :detail => "変更後食事"
      }

      response.should redirect_to weight_log_menus_path(@eric.weight_logs[1])
    end

    it "食事内容の変更でエラーが発生した場合は変更フォームが再表示される" do
      put :update, :weight_log_id => @eric.weight_logs[1].id, :id => @eric.weight_logs[1].menus[0].id, :menu => {
        :menu_type => nil,
        :detail => nil
      }

      response.should render_template "edit"
    end
  end

  describe "DELETE /weight_logs/:weight_log_id/menu/:id" do
    it "食事内容を削除した場合は食事履歴ページにリダイレクトする" do
      eric = FactoryGirl.create(:eric_with_weight_logs_with_menu)
      session[:id] = eric.id

      delete :destroy, :weight_log_id => eric.weight_logs[1].id, :id => eric.weight_logs[1].menus[2].id

      response.should redirect_to weight_log_menus_path
    end
  end

  after do
    FactoryGirl.reload
  end
end