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
end
