# encoding: utf-8
require 'spec_helper'

describe UsersController do
  describe "POST user" do
    it "ユーザが正常に新規登録できた場合は体重履歴ページにリダイレクトされる" do
      post :create, :user => {
        :mail_address => "newuser@mail.com",
        :display_name => "new user",
        :password => "pass9876"
      }

      response.should redirect_to weight_logs_path
    end

    it "ユーザの新規登録でエラーになる場合は新規登録フォームが再表示される" do
      post :create, :user => {
        :mail_address => nil
      }

      response.should render_template "new"
    end
  end

  describe "PUT user" do
    before do
      john = FactoryGirl.create(:john)
      session[:id] = john.id
    end

    it "ユーザの情報が正常に変更できた場合は体重履歴ページにリダイレクトされる" do
      put :update, :user => {
        :mail_address => "newuser@mail.com",
        :display_name => "neweric dominos",
        :password => "pass2345"
      }

      response.should redirect_to weight_logs_path
    end

    it "ユーザ情報の変更でエラーになる場合は変更フォームが再表示される" do
      put :update, :user => {
        :mail_address => nil,
        :display_name => "neweric",
        :password => "pass1234"
      }

      response.should render_template "edit"
    end
  end

  describe "DELETE user" do
    it "ユーザ情報の削除に成功した場合はログインページにリダイレクトされる" do
      delete :destroy

      response.should redirect_to login_path
      session[:id].should be_nil
    end
  end
end
