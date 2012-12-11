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

  end
end
