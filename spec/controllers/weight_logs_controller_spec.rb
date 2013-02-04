# encoding: utf-8
require 'spec_helper'

describe WeightLogsController do
  describe "PUT weight_logs" do
    before do
      @eric = FactoryGirl.create(:eric_with_weight_logs)
      session[:id] = @eric.id
    end

    it "体重履歴の更新が正常に終了した場合は体重履歴ページにリダイレクトされる" do
      put :update, :id => @eric.weight_logs[0].id, :weight_log => {
        :weight => 54,
        :measured_date => Date.yesterday,
        :fat_percentage => 16
      }

      response.should redirect_to weight_logs_path
    end

    it "体重履歴の更新でエラーが発生した場合は変更フォームが再表示される" do
      put :update, :id => @eric.weight_logs[0].id, :weight_log => {
        :weight => nil,
        :measured_date => nil,
        :fat_percentage => nil
      }

      response.should render_template "edit"
    end
  end

  describe "POST weight_log" do
    it "追加した体重履歴が目標を達成した場合はメッセージがflashに格納される" do
      john = FactoryGirl.create(:john_with_milestone)
      session[:id] = john.id

      expected_message = sprintf(I18n.t(:achieve_milestone, :scope => :application_messages), john.milestone.reward)

      post :create, :weight_log => {
        :weight => 64,
        :measured_date => Date.yesterday,
        :fat_percentage => 20.0
      }

      response.should redirect_to weight_logs_path
      flash[:success].should == expected_message
    end
  end

  describe "DELETE weight_log" do
    it "体重履歴を削除した場合は履歴ページにリダイレクトされる" do
      eric = FactoryGirl.create(:eric_with_weight_logs)
      session[:id] = eric.id

      delete :destroy, :id => eric.weight_logs[1]

      response.should redirect_to weight_logs_path
    end
  end

  after do
    FactoryGirl.reload
  end
end