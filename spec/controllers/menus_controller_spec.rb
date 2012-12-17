# encoding: utf-8

require 'spec_helper'

describe MenusController do
	describe "POST weight_logs/:id/menu" do
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
end