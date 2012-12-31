# encoding: utf-8
class Admin::ConfirmsController < ApplicationController
	before_filter :authenticate_user!

	def show
		# do nothing
	end

	def create
		password = params[:confirm][:password]

		if sign_in_as_admin(current_user.mail_address, password)
			redirect_to admin_menu_path
		else
			flash[:alert] = application_message(:administrator_confirm_incorrect)
			render "show"
		end
	end
end
