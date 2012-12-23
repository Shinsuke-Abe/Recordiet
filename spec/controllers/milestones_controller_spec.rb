# encoding: utf-8
require 'spec_helper'

describe MilestonesController do
  describe "POST milestone" do
    before do
      eric = FactoryGirl.create(:eric)
      session[:id] = eric.id
    end

    it "目標が正常に新規登録される場合は体重履歴ページにリダイレクトされる" do
      post :create, :milestone => {
        :weight => 65.0,
        :date => Date.tomorrow,
        :fat_percentage => 19.0,
        :reward => "テストご褒美"
      }

      response.should redirect_to weight_logs_path
    end

    it "目標の新規登録がエラーになる場合は新規登録フォームを再表示する" do
      post :create, :milestone => {
        :weight => nil
      }

      response.should render_template "new"
    end
  end

  describe "PUT milestone" do
    before do
      john = FactoryGirl.create(:john_with_milestone)
      session[:id] = john.id
    end

    it "目標が正常に変更できる場合は体重履歴ページにリダイレクトされる" do
      post :update, :milestone => {
        :weight => 65.9,
        :date => Date.tomorrow + 1.day,
        :fat_percentage => nil,
        :reward => "テストご褒美"
      }

      response.should redirect_to weight_logs_path
    end

    it "目標の変更でエラーが発生した場合は変更フォームを再表示する" do
      post :update, :milestone => {
        :weight => nil
      }

      response.should render_template "edit"
    end
  end

  after do
    FactoryGirl.reload
  end
end
