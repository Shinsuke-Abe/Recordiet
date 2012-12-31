# encoding: utf-8

require 'spec_helper'

describe LoginsController do
  describe "POST login" do
    it "ユーザ認証が成功する場合は履歴トップにリダイレクトされる" do
      john = FactoryGirl.create(:john)

      post :create, :user => {
        :mail_address => john.mail_address,
        :password => john.password
      }

      response.should redirect_to weight_logs_path
      session[:id].should eql john.id
    end

    it "ユーザ認証に失敗する場合はログイン画面を再表示する" do
      post :create, :user => {
        :mail_address => "notfounduser@mail.com",
        :password => "notfoundpass"
      }

      response.should render_template "show"
    end
  end

  describe "DELETE login" do
    it "管理者認証済のユーザがログアウトした場合はセッションから管理者認証も削除する" do
      admin = FactoryGirl.create(:admin)
      session[:id] = admin.id
      session[:is_administrator] = admin.is_administrator

      delete :destroy

      response.should redirect_to login_path

      session[:id].should be_nil
      session[:is_administrator].should be_nil
    end
  end

  after do
    FactoryGirl.reload
  end
end
