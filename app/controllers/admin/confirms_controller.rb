# encoding: utf-8
class Admin::ConfirmsController < ApplicationController
	before_filter :authenticate_user!

	def show
		# do nothing
	end

	def create
		password = params[:confirm][:password]

		if User.authenticate(current_user.mail_address, password)
			redirect_to admin_menu_path
		else
			render "show"
		end
	end
end
